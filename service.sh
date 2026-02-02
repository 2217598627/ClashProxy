#!/system/bin/sh

# 初始化变量
MODDIR=${0%/*}

# 开机完成后，等待30秒
while [ "$(getprop sys.boot_completed)" != "1" ]; do
  sleep 2
done
sleep 30

# 判断日志目录是否已经挂载，并清空日志文件
if ! mount | grep -q "${MODDIR}/log type tmpfs"; then
  mkdir -p ${MODDIR}/log >/dev/null 2>&1
  mount -t tmpfs -o size=512M,mode=0755 tmpfs ${MODDIR}/log
  echo "- [service.sh($(date +"%H:%M:%S"))]：日志文件夹挂载完成!" >>${MODDIR}/log/service_clash.log
fi

# 判断缓存目录是否已经挂载，并清空日志文件
if ! mount | grep -q "${MODDIR}/tmp type tmpfs"; then
  mkdir -p ${MODDIR}/tmp >/dev/null 2>&1
  mount -t tmpfs -o size=512M,mode=0755 tmpfs ${MODDIR}/tmp
  echo "- [service.sh($(date +"%H:%M:%S"))]：缓存文件夹挂载完成!" >>${MODDIR}/log/service_clash.log
fi

# 设置执行权限
chmod +x "${MODDIR}"/*.sh
chmod +x "${MODDIR}"/bin/*

# 启动守护脚本
setsid "${MODDIR}"/service_clash.sh >>"${MODDIR}"/log/service_clash.log 2>&1 &

# 退出脚本
exit 0
