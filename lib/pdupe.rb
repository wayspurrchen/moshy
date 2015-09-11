require 'aviglitch'
require 'optparse'

############
# pdupe.rb #
############

# OptionParser.new do |opts|
#   opts.banner = "Usage: example.rb [options]"

#   opts.on('-i', '--input path (required)', 'Input file - must be an .avi. Clip to split in split mode, first clip in stitch mode') { |v| $options[:input] = v }
#   opts.on('-o', '--output path (required)', 'Output file path - will be appended with -#.avi for each frame in split mode') { |v| $options[:output] = v }
#   opts.on('-f', '--frame number', 'Which nth frames should be duplicated', OptionParser::DecimalInteger) { |v| $options[:frame] = v }
#   opts.on('-k', '--keep', 'Whether or not to keep standard frames, defaults true') { |v| $options[:keep] = v }
#   opts.on('-d', '--dupes number', 'Clip begin index when in split mode', OptionParser::DecimalInteger) { |v| $options[:dupes] = v }
#   opts.on('-v', '--verbose', 'Noisy or not') { |v| $options[:verbose] = v }
# end.parse!


module Moshy
	class PDupe
		def initialize(args)
			opts = Slop::Options.new
			opts.separator 'Required Parameters:'
			opts.string '-i', '--input', 'Input file path - must be an .avi. Clip to split in split mode, first clip in stitch mode'
			opts.string '-o', '--output', 'Output file path - will be appended with -#.avi for each frame in split mode'
			opts.integer '-f', '--frame', 'Index of the frame that should be duplicated'
			opts.separator 'Optional Parameters:'
			opts.integer '-d', '--dupes', 'Number of times to multiply the frame (default: 30)'

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

			# ploop(clip, $options[:interval], $options[:dupes], $options[:keep])
		end

		# Loops through a video file and grabs every `interval` frames then duplicates them
		# `duplicate_amount` times
		# 
		# `leave_originals` will copy standard frames and only p-frame the last one every `interval`
		def ploop(clip, interval, duplicate_amount, leave_originals)

			puts "Size: " + clip.frames.size_of('videoframe').to_s

			frames = nil
			video_frame_counter = 0

			clip.frames.each_with_index do |f, i|
				if f.is_videoframe?
					video_frame_counter += 1
					if video_frame_counter == $options[:frame]
						puts "On frame " + $options[:frame].to_s + ", duping"
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
			o.output $options[:output]
		end
	end
end
