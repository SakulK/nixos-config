source=$(ponymix -t source list|awk '/^source/ {s=$1" "$2;getline;gsub(/^ +/,"",$0);print s" "$0}'|rofi -dmenu -p 'pulseaudio source:'|grep -Po '[0-9]+(?=:)') &&
	ponymix set-default -d "$source" -t source &&
	for output in $(ponymix list -t source-output|grep -Po '[0-9]+(?=:)');do
		echo "$output -> $source"
		ponymix -t source-output -d "$output" move "$source"
	done
