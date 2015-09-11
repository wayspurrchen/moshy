require 'aviglitch'
require 'slop'

module Moshy
	class ISplit
		def initialize(args)
			opts = Slop::Options.new
			opts.separator 'Required Parameters:'
			opts.string '-i', '--input', 'Input file path - must be an .avi. Clip to split in split mode, first clip in stitch mode'
			opts.string '-o', '--output', 'Output file path - will be appended with -#.avi for each frame in split mode'
			opts.separator 'Optional Parameters:'
			opts.integer '-b', '--begin', 'Index of the I-frame at which to begin clipping (inclusive)'
			opts.integer '-e', '--end', 'Index of the I-frame at which to stop clipping (inclusive)'

			parser = Slop::Parser.new(opts)
			@options = parser.parse(ARGV)
			# puts @options.to_hash

			# Check mandatory params
			mandatory = [:input, :output]
			missing = mandatory.select{ |param| @options[param].nil? }
			unless missing.empty?
				puts "Missing options: #{missing.join(', ')}"
				puts @options
				exit
			end


			puts "Opening file " + @options[:input] + "..."
			a = AviGlitch.open @options[:input]       # Rewrite this line for your file.
			puts "Opened!"

			split(a)
		end

		def clip(frames, out_path, start_index, frame_count)
			puts "Clipping " + frame_count.to_s + " frames starting at frame " + start_index.to_s
			clip = frames.slice(start_index, frame_count)
			o = AviGlitch.open clip
			puts "Outputting " + out_path
			o.output out_path
		end

		def split(clip)
			clip_cuts = {}

			clip_count = 0
			current_iframe = 0
			iframe_index = 0
			last_iframe_index = 0
			frames_in_clip = 0

			# Harvest clip details
			total_frame_count = clip.frames.count
			clip.frames.each_with_index do |f, i|
				if f.is_keyframe?
					iframe_index = i
					# Don't process frames that are before our beginning
					if current_iframe and @options[:begin] and current_iframe < @options[:begin]
						# puts "skipping " + current_iframe.to_s
						frames_in_clip = 0
						current_iframe = current_iframe + 1
						last_iframe_index = iframe_index
						# puts "last_iframe_index: " + last_iframe_index.to_s
						next
					end
					break if @options[:end] and current_iframe > @options[:end]

					if current_iframe != 0
						if @options[:verbose]
							puts "Storing clip details: iframe_number=" + current_iframe.to_s + "; index=" + last_iframe_index.to_s + "; frame_count=" + frames_in_clip.to_s
						end
						clip_cuts[current_iframe] = {
							:index => last_iframe_index,
							:frame_count => frames_in_clip
						}
					end
					frames_in_clip = 0
					current_iframe = current_iframe + 1
					last_iframe_index = iframe_index
				else
					frames_in_clip = frames_in_clip + 1
					# clip last piece manually if we're at the end, because there's
					# no last iframe to detect and trigger the final clip
					if i == total_frame_count - 1
						if @options[:verbose]
							puts "Storing clip details: iframe_number=" + current_iframe.to_s + "; index=" + last_iframe_index.to_s + "; frame_count=" + frames_in_clip.to_s
						end
						clip_cuts[current_iframe] = {
							:index => last_iframe_index,
							:frame_count => frames_in_clip
						}
					end
				end
			end

			puts clip_cuts

			clip_cuts.keys.each do |f|
				out_path = @options[:output] + '-' + f.to_s + '.avi'
				clip(clip.frames, out_path, clip_cuts[f][:index], clip_cuts[f][:frame_count])
			end

			puts "All done!"
		end
	end
end
