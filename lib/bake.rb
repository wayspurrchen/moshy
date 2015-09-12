module Moshy
	class Bake
		def initialize(args)
			opts = Slop::Options.new
			opts.separator 'Required Parameters:'
			opts.string '-i', '--input', 'Input file path - can be anything that ffmpeg supports.'
			opts.string '-o', '--output', 'File output path - should end in .avi.'
			opts.separator 'Optional Parameters:'
			opts.integer '-b', '--bitrate', 'Bitrate amount (kb/s). Defaults to 4196. Larger number means higher quality, but larger size.'
			opts.string '-p', '--pframes', 'Makes sure that there are only P-Frames (no B-Frames). Set this true if you plan to mosh your baked file again. Defaults false.'
			opts.integer '-n', '--iframe-interval', 'Ideal interval for I-Frames to be distributed. Set this to a high number (600) if you plan to mosh your baked file again.'

			default = {
				:bitrate => 4196
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

			if @options[:pframes] == "false"
				@options[:pframes] = false
			else
				@options[:pframes] = true
			end

			# Check mandatory params
			mandatory = [:input, :output]
			missing = mandatory.select{ |param| @options[param].nil? }
			unless missing.empty?
				puts "Missing options: #{missing.join(', ')}"
				puts slop_options
				exit
			end

			prep @options[:input]
		end

		def prep(file)
			ffmpeg = Av::Commands::Ffmpeg.new
			ffmpeg.add_source file
			ffmpeg.add_destination @options[:output]

			# Ensures all frames come out as P-frames, B-frames don't
			# dupe or mosh properly
			if @options[:pframes]
				ffmpeg.add_output_param ['bf', 0]
			end

			# Keyframe interval, sets as few I-frames as possible.
			# ffmpeg will complain about anything over 600 and cap it.
			if @options[:'iframe-interval']
				ffmpeg.add_output_param ['g', @options[:'iframe-interval'].to_s]
			end

			# Bitrate
			ffmpeg.add_output_param ['b:v', @options[:bitrate].to_s + 'k']

			ffmpeg.run
		end
	end
end
