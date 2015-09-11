require_relative 'lib/isplit'
require_relative 'lib/pdupe'
# require_relative 'lib/ploop'
require 'optparse'
require 'slop'

module Moshy
	def self.top_level_help
		$options = {

		}
		opts = OptionParser.new do |opts|
			opts.banner = "
moshy, a Ruby utility for making it easier to datamosh AVI files. It has
multiple modes that can be run with the -m or --mode option.

	MODES
	-----

	\"isplit\" - Extracts individual clips from an AVI where each clip is
	separated by I-frames in the original AVI. Great for getting specific
	clips out of a larger video and later doing I-frame moshing.
	\"pdupe\" - Duplicates a P-frame at a given frame a certain amount. To find
	out which frames are P-frames, use software like avidemux to look at the
	frame type. WARNING: This mode is a little glitchy. You may need to set
	the interval 1 or 2 above or below the frame number you actually want to
	duplicate. I'm not sure why this happens, but try it with a small
	duplication amount first. NOTE: This can mode take a while to process
	over 60-90 frame dupes.
	\"ploop\" - Takes every n frames and duplicates them a given amount,
	resulting in a consistent P-duplication datamosh that's good for creating
	rhythmic effects. This was originally created to create mosh effects in
	sync with a beat for a music video.

Run moshy with mode -m <mode> --help to see options for individual modes.
	"
		end

		begin
		    opts.parse
		rescue OptionParser::InvalidOption, OptionParser::InvalidArgument
		end

		puts opts
	end
end

# Because we have multiple modes, we do some initial basic arg checking
# to see if they specified a mode. If not, we show the top-level help menu.
result = Slop.parse suppress_errors: true do |o|
  o.string '-m', '--mode'
end

if result[:m] == "isplit" || result[:m] == "pdupe" || result[:m] == "ploop"
	# We need to strip out the "m" otherwise our other arg parsers
	# will choke on the extra parameter
	ARGV.each_with_index do |o, i|
		if o == "-m" || o == "--m"
			ARGV.delete_at(i + 1)
			ARGV.delete_at(i)
			break
		end
	end

	case result[:m]
	when "isplit"
		Moshy::ISplit.new(ARGV)
	when "pdupe"
		Moshy::PDupe.new(ARGV)
	when "ploop"
		# Moshy::PDupe.new(ARGV)

	end
else
	Moshy.top_level_help
end