mod_handler() {

MODLIST=$1
IFS=' '
for mod in $MODLIST; do
	case $mod in
		"static")
			[[ $(echo "$PLATFORM_CANDIDATES" | grep "linux") != "" ]] && sed -ibak "/static/s/^#unix/unix/" CellFrameDashboard.pro && [ ! -z "ICU_LINUX_PATH" ] && sed -ibak "s!ICU_LINUX_PATH!$ICU_LINUX_PATH!" CellFrameDashboard.pro && \
			PLATFORM_CANDIDATES=$( echo $PLATFORM_CANDIDATES | sed "s/linux\/[a-z]\+ \?//g" | sed "s/$/ linux/" | sed "s/^ //") || sed -ibak "/static/s/^unix/#unix/" CellFrameDashboard.pro #For toggling static mode
			;;
		*)
			echo "No handling required for mod $mod. Proceeding"
			;;
	esac
done
IFS='\n'
}
