module Moshy
	class Prep
		def initialize(args)
			opts = Slop::Options.new
			opts.banner = "Usage: moshy.rb -m prep -i <file> -o <output> [options]\n"
			opts.separator 'Required Parameters:'
			opts.string '-i', '--input', 'Input file path - can be anything that ffmpeg supports.'
			opts.string '-o', '--output', 'File output path - should end in .avi.'
			opts.separator 'Optional Parameters:'
			opts.integer '-b', '--bitrate', 'Bitrate amount (kb/s). Defaults to 4196. Larger number means higher quality, but larger size.'
			opts.on '-h', '--help' do
				puts opts
				puts "\n"
				puts \
"Preps a video file for datamoshing with moshy by converting it into an
AVI with no B-Frames (they're not good for moshing), and placing as
few I-Frames as possible. Requires ffmpeg be installed locally. Check
the repository's README.md for more information on how to install ffmpeg.

This command is meant to be a simple one-liner that makes your datamoshing
workflow faster. Under the covers, it runs the following ffmpeg command:

ffmpeg -i <moshy input> -bf 0 -g 600 -b:v <moshy bitrate> -o <moshy output>

This takes in an input file (it should theoretically work with any video
file type that ffmpeg supports), makes sure that no B-Frames are rendered,
and sets the ideal I-frame interval to 600 (ffmpeg's max). This seems to
mean that an I-frame will only show up every 30 to 25 seconds
(600f / 30fps = 20s or 600f / 24fps = 25s), but I-Frames must be deposited
wherever there is a hard cut or transition in a video where a P-frame would
not be able to properly predict the motion of pixels."
				exit
			end

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
			ffmpeg.add_output_param ['bf', 0]
			# Keyframe interval, sets as few I-frames as possible.
			# ffmpeg will complain about anything over 600 and cap it.
			ffmpeg.add_output_param ['g', 600]
			# Bitrate
			ffmpeg.add_output_param ['b:v', @options[:bitrate].to_s + 'k']

			ffmpeg.run
		end
	end
end
