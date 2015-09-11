require 'aviglitch'
require 'optparse'

############
# ploop.rb #
############

# This grabs intervals of frames from a file and duplicates them a given amount,
# concatenating them all together


$options = {
	:interval => 15,
	:dupes => 30,
	:keep => true
}

OptionParser.new do |opts|
  opts.banner = "Usage: example.rb [options]"

  opts.on('-i', '--input path (required)', 'Input file - must be an .avi. Clip to split in split mode, first clip in stitch mode') { |v| $options[:input] = v }
  opts.on('-o', '--output path (required)', 'Output file path - will be appended with -#.avi for each frame in split mode') { |v| $options[:output] = v }
  opts.on('-n', '--interval number', 'Which nth frames should be duplicated', OptionParser::DecimalInteger) { |v| $options[:interval] = v }
  opts.on('-k', '--keep', 'Whether or not to keep standard frames, defaults true') { |v| $options[:keep] = v }
  opts.on('-d', '--dupes number', 'Clip begin index when in split mode', OptionParser::DecimalInteger) { |v| $options[:dupes] = v }
  opts.on('-b', '--begin number', 'Clip begin index when in split mode', OptionParser::DecimalInteger) { |v| $options[:begin] = Integer(v) }
  opts.on('-e', '--end number', 'Clip end index when in split mode', OptionParser::DecimalInteger) { |v| $options[:end] = Integer(v) }
  opts.on('-v', '--verbose', 'Noisy or not') { |v| $options[:verbose] = v }
end.parse!

# Require mandatory flags
begin
  mandatory = [:input, :output]
  missing = mandatory.select{ |param| $options[param].nil? }
  unless missing.empty?
    puts "Missing options: #{missing.join(', ')}"
    puts optparse
    exit
  end
rescue OptionParser::InvalidOption, OptionParser::MissingArgument
  puts $!.to_s
  puts optparse
  exit
end

# Loops through a video file and grabs every `interval` frames then duplicates them
# `duplicate_amount` times
# 
# `leave_originals` will copy standard frames and only p-frame the last one every `interval`
def ploop(clip, interval, duplicate_amount, leave_originals)

	puts "Size: " + clip.frames.size_of('videoframe').to_s

	frames = nil

	video_frame_counter = 0
	selected_video_frame = 0

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
					dupe_clip = clip.frames[i, 5] * duplicate_amount
					if frames.nil?
						frames = clipped + dupe_clip
					else
						frames = frames + clipped + dupe_clip
					end
					puts frames.size.to_s

					first_index = i
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
					frames = clip.frames[i, 5]
					have_iframe = true
				end
				video_frame_counter += 1
				if video_frame_counter % interval == 0 && f.is_deltaframe?
					if $options[:begin] && selected_video_frame < $options[:begin]
						puts selected_video_frame.to_s + " less than " + $options[:begin].to_s
						selected_video_frame += 1
						next
					elsif $options[:end] && selected_video_frame > $options[:end]
						puts selected_video_frame.to_s + " greater than " + $options[:end].to_s
						break
					end

					puts "Processing frame " + video_frame_counter.to_s + " at index " + i.to_s
					if frames.nil?
						puts "First frame, setting"
						clipped = clip.frames[i, 5]
						frames = frames.concat( clipped * duplicate_amount )
						puts "Frame size"
						puts frames.size_of('videoframe')
					else
						frames = frames.concat( clip.frames[i, 5] * duplicate_amount )
						puts "Next frame, size: " + frames.size.to_s
					end
					selected_video_frame += 1
				end
			end
		end
	end

	o = AviGlitch.open frames
	o.output $options[:output]
end

puts "Opening file " + $options[:input] + "..."
clip = AviGlitch.open $options[:input]       # Rewrite this line for your file.
puts "Done!"
ploop(clip, $options[:interval], $options[:dupes], $options[:keep])