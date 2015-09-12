module Moshy
	class Inspect
		def cli(args)
			opts = Slop::Options.new
			opts.banner = "Usage: moshy -m inspect -i file.avi\nmoshy -m inspect --help for details"
			opts.separator 'Required Parameters:'
			opts.string '-i', '--input', 'Input file path - must be an .avi.'
			opts.on '-h', '--help' do
				puts opts
				puts "\n"
				puts \
"Reads an .avi file and prints which video frames are keyframes (I-Frames)
and which frames are delta frames (P-frames or B-frames). moshy can't
tell the difference between a P-frame or a B-frame, so you will want
to use avidemux or another program if you need to know.

This is most useful for identifying where I-Frames exist without having
to manually seek through them in a video player/editor. Works well with
moshy's \"isplit\" mode because you can use the I-frames from inspect's
output to decide what segment of clips you want to get by their I-frames.

The output reads like this:

0: keyframe
1..359: deltaframe
360: keyframe
361..441: deltaframe

Large video files will output a lot of text, so you may want to write the
output to an external file like this:

moshy -m inspect -i video.avi > inspect.txt"
				exit
			end

			parser = Slop::Parser.new(opts)
			@options = parser.parse(ARGV)

			# Check mandatory params
			mandatory = [:input]
			missing = mandatory.select{ |param| @options[param].nil? }
			unless missing.empty?
				puts "Missing options: #{missing.join(', ')}"
				puts @options
				exit
			end

			puts "Opening file " + @options[:input] + "..."
			a = AviGlitch.open @options[:input]       # Rewrite this line for your file.
			puts "Opened!"

			inspect(a)
		end

		def inspect(clip)
			keyframe_counter = 0
			video_frame_counter = 0
			last_video_frame = 0
			start_of_frame_segment = 0
			last_type = nil
			type = nil
			# Harvest clip details
			total_frame_count = clip.frames.count
			clip.frames.each_with_index do |f, i|
				if f.is_videoframe?
					if f.is_keyframe?
						type = "keyframe"
					elsif f.is_deltaframe?
						type = "deltaframe"
					end

					if video_frame_counter == 0
						last_type = type
					end

					if type == last_type
						last_video_frame = video_frame_counter
					else
						# Found a new type segment, print out what we've got
						if start_of_frame_segment + 1 == last_video_frame
							segment_string = start_of_frame_segment.to_s + ": " + last_type
						else
							segment_string = start_of_frame_segment.to_s + ".." + (last_video_frame - 1).to_s + ": " + last_type
						end
						# Let's not add this so we don't confuse the user by making
						# them think they want to use isplit according to the keyframe count
						# if last_type == "keyframe"
						# 	segment_string += " " + keyframe_counter.to_s
						# 	keyframe_counter += 1
						# end
						puts segment_string

						# The new last type will be this type during the next frame segment
						last_type = type
						# Update start of the frame segment to this frame
						start_of_frame_segment = video_frame_counter
					end
				end
				video_frame_counter += 1
				last_video_frame = video_frame_counter
			end
			if start_of_frame_segment + 1 == last_video_frame
				puts start_of_frame_segment.to_s + ": " + last_type
			else
				puts start_of_frame_segment.to_s + ".." + (last_video_frame - 1).to_s + ": " + last_type
			end
			puts "All done!"
		end
	end
end
