mkdir /tmp/acd
cdparanoia -B "1-" /tmp/acd/
for file in /tmp/acd/*.cdda.wav; do
	if [ -f "$file" ]; then
		output=$(basename "$file" .wav)
		ffmpeg -i "$file" -vn -ar 44100 -ac 2 -b:a 192k "${output}.mp3"
	fi
done
rm -r /tmp/acd
