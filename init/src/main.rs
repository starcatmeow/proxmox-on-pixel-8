#![feature(panic_payload_as_str)]
use std::{env::current_dir, ffi::CString, fs::{create_dir, File, OpenOptions}, io::Write, iter::once, panic, process, ptr::null, sync::Mutex};

use chrono::Utc;
use log::{error, info};
use syscalls::{syscall, Sysno};

struct FsLogger {
    log_file: Mutex<File>,
}

impl FsLogger {
    fn new(target: &str) -> FsLogger {
        FsLogger {
            log_file: Mutex::new(OpenOptions::new().write(true).append(true).create(true).open(target).unwrap())
        }
    }
}
impl log::Log for FsLogger {
    fn enabled(&self, _metadata: &log::Metadata) -> bool {
        true
    }
    fn log(&self, record: &log::Record) {
        self.log_file.lock().unwrap().write(format!("{} [{}] {}:{} {}\n", Utc::now().format("%+"), record.level().as_str(), record.file().unwrap_or("unknown"), record.line().unwrap_or(0), record.args()).as_bytes()).unwrap();
        self.log_file.lock().unwrap().flush().unwrap();
    }
    fn flush(&self) {
        self.log_file.lock().unwrap().flush().unwrap();
    }
}
fn mount(src: &str, dst: &str, fstype: &str, flag: usize, data: usize) {
    let src = CString::new(src).unwrap();
    let dst = CString::new(dst).unwrap();
    let fstype = CString::new(fstype).unwrap();
    unsafe {
        syscall!(Sysno::mount, src.as_ptr(), dst.as_ptr(), fstype.as_ptr(), flag, data).unwrap();
    }
}
fn chroot(path: &str) {
    let path = CString::new(path).unwrap();
    unsafe {
        syscall!(Sysno::chroot, path.as_ptr()).unwrap();
    }
}
fn execve(path: &str, argv: Vec<String>, envp: Vec<String>) {
    let path = CString::new(path).unwrap();
    let argv = argv.into_iter().map(|arg| CString::new(arg).unwrap()).collect::<Vec<CString>>();
    let argv: Vec<*const u8> = argv.iter().map(|arg| arg.as_c_str().as_ptr()).chain(once(null())).collect();
    let envp = envp.into_iter().map(|arg| CString::new(arg).unwrap()).collect::<Vec<CString>>();
    let envp: Vec<*const u8> = envp.iter().map(|arg| arg.as_c_str().as_ptr()).chain(once(null())).collect();
    unsafe {
        syscall!(Sysno::execve, path.as_c_str().as_ptr(), argv.as_slice().as_ptr(), envp.as_slice().as_ptr()).unwrap();
    }
}
fn chdir(path: &str) {
    let path = CString::new(path).unwrap();
    unsafe {
        syscall!(Sysno::chdir, path.as_ptr()).unwrap();
    }
}
fn init_log() {
    create_dir("devtmp").unwrap();
    mount("devtmpfs", "devtmp", "devtmpfs", 0, 0);
    create_dir("mntstorage").unwrap();
    mount("devtmp/sda34", "mntstorage", "ext4", 0, 0);
    let logger = Box::leak(Box::new(FsLogger::new("mntstorage/log")));
    log::set_logger(logger).unwrap();
    log::set_max_level(log::LevelFilter::Info);
    panic::set_hook(Box::new(|info| {
        error!("Panic: payload={:?}, location={:?}", info.payload_as_str(), info.location());
    }));
}
const MS_BIND: usize = 4096;
fn mount_dlkm(dlkm_path: &str, dst_os: &str) {
    info!("mount dlkm");
    mount(format!("{}{}",dlkm_path,"/vendor").as_str(), format!("{}{}",dst_os,"/vendor").as_str(), "", MS_BIND, 0);
    mount(format!("{}{}",dlkm_path,"/system").as_str(), format!("{}{}",dst_os,"/system").as_str(), "", MS_BIND, 0);
    mount(format!("{}{}",dlkm_path,"/vendor_dlkm").as_str(), format!("{}{}",dst_os,"/vendor_dlkm").as_str(), "", MS_BIND, 0);
    mount(format!("{}{}",dlkm_path,"/system_dlkm").as_str(), format!("{}{}",dst_os,"/system_dlkm").as_str(), "", MS_BIND, 0);
}
fn launch_debian(path: &str) {
    create_dir("sysroot").unwrap();
    info!("bind mount debian rootfs");
    mount(path, "sysroot", "", MS_BIND, 0);
    mount_dlkm("mntstorage/dlkm", "sysroot");
    info!("chroot");
    chroot("sysroot");
    chdir("/");
    info!("execve to /sbin/init!");
    execve("/sbin/init", vec!["/sbin/init".into()], vec!["PATH=/bin:/sbin:/usr/bin:/usr/sbin".into()])
}
fn main() {
    init_log();
    info!("Hello from rust init! PID={}, cwd={}", process::id(), current_dir().unwrap().to_str().unwrap());
    launch_debian("mntstorage/debian-rootfs");
}
