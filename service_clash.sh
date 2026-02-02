#/system/bin/sh

# 初始化变量
MODDIR=${0%/*}
pid_clash_service=$$

# 初始化PID文件
echo '!' >${MODDIR}/tmp/clash.pid
echo "${pid_clash_service}" >${MODDIR}/tmp/clash_service.pid
echo "- [service_clash.sh($(date +"%H:%M:%S"))]：PID文件初始化完成！" >>${MODDIR}/tmp/clash_service.pid

# 设置守护脚本核心数量
echo "${pid_clash_service}" >>/dev/cpuset/display/tasks
echo "- [service_clash.sh($(date +"%H:%M:%S"))]：守护脚本核心数量设置完成！" >>${MODDIR}/log/service_clash.log

# 指令整合
pid_bin_clash() {
  cat ${MODDIR}/tmp/clash.pid | tr -d '\r\n'
}
bin_clash() {
  setsid "${MODDIR}"/bin/clash -d "${MODDIR}"/clash_config >"${MODDIR}"/log/clash.log 2>&1 &
  echo "$(pgrep -x -n 'clash')" >${MODDIR}/tmp/clash.pid
  echo "$(pid_bin_clash)" >>/dev/cpuset/display/tasks
  echo "- [service_clash.sh($(date +"%H:%M:%S"))]：Clash核心数量设置完成！" >>${MODDIR}/log/service_clash.log
}
kill_bin_clash() {
  killall 'clash' >/dev/null 2>&1
  echo '!' >${MODDIR}/tmp/clash.pid
}
reboot_bin_clash() {
  killall 'clash' >/dev/null 2>&1
  setsid "${MODDIR}"/bin/clash -d "${MODDIR}"/clash_config >"${MODDIR}"/log/clash.log 2>&1 &
  echo "$(pgrep -x -n 'clash')" >${MODDIR}/tmp/clash.pid
  echo "$(pid_bin_clash)" >>/dev/cpuset/display/tasks
  echo "- [service_clash.sh($(date +"%H:%M:%S"))]：Clash核心数量设置完成！" >>${MODDIR}/log/service_clash.log
}

# 主循环守护
while true; do
  sleep 5
  if [ -f "${MODDIR}/disable" ]; then 
    if [ -d "/proc/$(pid_bin_clash)" ]; then
      kill_bin_clash
      echo "- [service_clash.sh($(date +"%H:%M:%S"))]：模块已禁用,程序自动关闭!" >>${MODDIR}/log/service_clash.log
    fi
  else
    if [ ! -d "/proc/$(pid_bin_clash)" ]; then
      bin_clash
      echo "- [service_clash.sh($(date +"%H:%M:%S"))]：核心进程不存在,已启动完成! ($(pid_bin_clash))" >>${MODDIR}/log/service_clash.log
    fi
  fi
done
