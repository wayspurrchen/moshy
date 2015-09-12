require 'aviglitch'
require 'slop'

module Moshy
	class PDupe
		def initialize(args)
			opts = Slop::Options.new
			opts.banner = "Usage: moshy -m pdupe -i file.avi -o file_out.avi -f <integer>\nmoshy -m pdupe --help for details"
			opts.separator 'Required Parameters:'
			opts.string '-i', '--input', 'Input file path - must be an .avi.'
			opts.string '-o', '--output', 'Output file path, should be an .avi.'
			opts.integer '-f', '--frame', 'Index of the frame that should be duplicated'
			opts.separator 'Optional Parameters:'
			opts.integer '-d', '--dupes', 'Number of times to multiply the frame (default: 30)'
			opts.on '-h', '--help' do
				puts opts
				puts "\n"
				puts \
"Duplicates a P-frame at a given frame a certain amount. To find
out which frames are P-frames, use software like avidemux to look at the
frame type. WARNING: This mode is a little glitchy. You may need to set
the interval 1 or 2 above or below the frame number you actually want to
duplicate. I'm not sure why this happens, but try it with a small
duplication amount first. NOTE: This can mode take a while to process
over 60-90 frame dupes.

You can specify the number of duplicates that you want with the -d parameter."
				exit
			end

			default = {
				:dupes => 30
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

			# Check mandatory params
			mandatory = [:input, :output, :frame]
			missing = mandatory.select{ |param| @options[param].nil? }
			unless missing.empty?
				puts "Missing options: #{missing.join(', ')}"
				puts slop_options
				exit
			end

			puts "Opening file " + @options[:input] + "..."
			a = AviGlitch.open @options[:input]       # Rewrite this line for your file.
			puts "Opened!"

			pdupe(a, @options[:interval], @options[:dupes], @options[:keep])
		end

		# Loops through a video file and grabs every `interval` frames then duplicates them
		# `duplicate_amount` times
		# 
		# `leave_originals` will copy standard frames and only p-frame the last one every `interval`
		def pdupe(clip, interval, duplicate_amount, leave_originals)

			puts "Size: " + clip.frames.size_of('videoframe').to_s

			frames = nil
			video_frame_counter = 0

			clip.frames.each_with_index do |f, i|
				if f.is_videoframe?
					video_frame_counter += 1
					if video_frame_counter == @options[:frame]
						puts "On frame " + @options[:frame].to_s + ", duping " + @options[:dupes].to_s + " times"
						clipped = clip.frames[0..(i + 5)]
						dupe_clip = clip.frames[(i + 4), 2] * duplicate_amount
						frames = clipped + dupe_clip
						puts "Added dupe, grabbing rest..."
						frames = frames + clip.frames[i..-1]
						puts "Done. Output frame count: " + frames.size.to_s
						break
					end
				end
			end

			o = AviGlitch.open frames
			o.output @options[:output]
		end
	end
end
