module Moshy
	class PPulse
		def cli(args)
			opts = Slop::Options.new
			opts.banner = "Usage: moshy -m ppulse -i file.avi -o file_out.avi [options]\nmoshy -m inspect --help for details"
			opts.separator 'Required Parameters:'
			opts.string '-i', '--input', 'Input file path - must be an .avi. Clip to split in split mode, first clip in stitch mode'
			opts.string '-o', '--output', 'Output file path - will be appended with -#.avi for each frame in split mode'
			opts.separator 'Optional Parameters:'
			opts.string '-k', '--keep', 'Whether or not to keep standard frames. (default: true)', default: "true"
			opts.integer '-c', '--count', 'How many frames to grab forward from each interval. (default: 1)', default: 1
			opts.integer '-d', '--dupes', 'Number of times to multiply the frame (default: 30)', default: 30
			opts.integer '-n', '--interval', 'Which nth frames should be duplicated (default: 30)', default: 30
			opts.on '-h', '--help' do
				puts opts
				puts "\n"
				puts \
"Takes c number of frames and every n frames and duplicates them a
given amount, resulting in a consistent P-duplication datamosh that's
good for creating rhythmic effects. This was originally created to
create mosh effects in sync with a beat for a music video.

You can specify what interval to get frames at with -n (--interval).
You can specify how many frames to get from the current interval with
-c (--count). You can specify how many times to duplicate a given
frame with -d (--dupes). You can then specify whether or not to keep
the original video's frames between the end of the duplication and
where the next interval occurs with -k (--keep). Keeping original
frames causes the original motion to continue after the P-frame dupe
effect, whereas dropping original frames causes the video to snap
into the motion of the frames at each interval. This is a more complex
effect so I recommend experimenting with it!"
				exit
			end

			default = {
				:dupes => 30,
				:interval => 30,
				:count => 1,
				:keep => true
			}

			parser = Slop::Parser.new(opts)
			slop_options = parser.parse(ARGV)
			@options = default.merge(slop_options) { |key, oldval, newval|
				if newval.nil?
					oldval
				else
					newval
				end
			}

			if @options[:keep] == "false"
				@options[:keep] = false
			else
				@options[:keep] = true
			end

			# Check mandatory params
			mandatory = [:input, :output]
			missing = mandatory.select{ |param| @options[param].nil? }
			unless missing.empty?
				puts "Missing options: #{missing.join(', ')}"
				puts slop_options
				exit
			end

			puts "Opening file " + @options[:input] + "..."
			a = AviGlitch.open @options[:input]       # Rewrite this line for your file.
			puts "Opened!"

			ppulse(a, @options[:output], @options[:interval], @options[:count], @options[:dupes], @options[:keep])
		end

		# Loops through a video file and grabs every `interval` frames then duplicates them
		# `duplicate_amount` times
		# 
		# `leave_originals` will copy standard frames and only p-frame the last one every `interval`
		def ppulse(clip, output, interval = 30, count = 1, duplicate_amount = 30, leave_originals = true)

			puts "Size: " + clip.frames.size_of('videoframe').to_s

			frames = nil

			video_frame_counter = 0

			have_iframe = false

			if leave_originals
				first_index = 0
				second_index = 0
				clip.frames.each_with_index do |f, i|
					if f.is_videoframe?
						video_frame_counter += 1
						if video_frame_counter % interval == 0
							second_index = i
							puts "first index: " + first_index.to_s
							puts "second index: " + second_index.to_s

							clipped = clip.frames[first_index..(i + 5)]
							dupe_clip = clip.frames[i, count] * duplicate_amount
							if frames.nil?
								frames = clipped + dupe_clip
							else
								frames = frames + clipped + dupe_clip
							end
							puts "Current expected output frame count: " + frames.size.to_s

							first_index = i + 5
						end
					end
				end
			else
				# Harvest clip details
				clip.frames.each_with_index do |f, i|
					if f.is_videoframe?
						if !have_iframe && f.is_keyframe?
							puts "Added first iframe (necessary to avoid total corruption)"
							# no idea why i need to get 5
							frames = clip.frames[i, 1]
							have_iframe = true
						end

						# +1 to offset the first iframe
						if video_frame_counter % interval == 0 && f.is_deltaframe?
							puts "Processing frame " + video_frame_counter.to_s + " at index " + i.to_s
							# You might ask why we need to check if frames are nil when we already check
							# whether or not we have an i frame and if the above is a keyframe - that's
							# because datamoshers are crazy and might pass use clip with no leading iframe :)
							if frames.nil?
								puts "First frame, setting"
								clipped = clip.frames[i, count]
								frames = frames.concat( clipped * duplicate_amount )
								puts "Frame size"
								puts frames.size_of('videoframe')
							else
								puts "Current i: " + i.to_s
								puts "Duping frame " + i.to_s + " " + duplicate_amount.to_s + " times"
								frames = frames.concat( clip.frames[i, count] * duplicate_amount )
								puts "Next frame, size: " + frames.size.to_s
							end
						end
						video_frame_counter += 1
					end
				end
			end

			o = AviGlitch.open frames
			o.output output
			puts "Done! File processed to: " + output
		end
	end
end
