#! /usr/bin/env ruby 

require_relative 'parser'

class Assembler
	def initialize(asm_file, hack_file)
		@asm_file = asm_file
		@hack_file = hack_file
		@parser = Parser.new(instructions_from_file)
	end

	def assemble!
		@parser.parse.each { |instruction| @hack_file << instruction << "\n" }
	end

	def instructions_from_file
		lines = @asm_file.readlines
		lines.each { |line| line.gsub! /\/\/.*/, ''; line.strip! }
		lines.delete("")

		labels = get_labels(lines)
		numVariables = 0
		lines.each do |line|
			if line.include? '('
				line.gsub! /\(\w+\)/, ''
			elsif line.include? '@'
				if line.match(/R[\d]{1,2}/)
					line.gsub! /R[\d]+/, line[2..-1]
				elsif labels.has_key? line[1..-1]
					line.gsub! line[1..-1], labels[line[1..-1]].to_s
				elsif not line.match(/@\d+/)
					labels[line[1..-1]] = 16 + numVariables
				end 
			end
		end
		lines.delete('')
		lines	
	end

	def get_labels(lines)
		labels = {
			'SP' => 0, 
			'LCL' => 1,
			'ARG' => 2,
			'THIS' => 3,
			'THAT' => 4,
			'SCREEN' => 16384,
			'KBD' => 24576
		}
		lineNum = 0
		numLabels = 0
		lines.each do |line|
			if line.include? '('
				labels[line[1..-2]] = lineNum - numLabels
				numLabels += 1
			end
			lineNum += 1
		end
		labels
	end

end



#---------------------------------------------------------------------------------------------------------
#                                                    File Check/Open 
#---------------------------------------------------------------------------------------------------------

def args_valid?
	ARGV[0] && ARGV[0].end_with?(".asm") && ARGV.length == 1
end

def is_readable?(path)
	File.readable?(path)
end

def hack_filename(asm_filename)
	asm_basename = File.basename(asm_filename, ".asm")
	path = File.split(asm_filename)[0]
	"#{path}/#{asm_basename}.hack"
end

unless args_valid?
	abort("Usage: ./assembler.rb Prog.asm")
end
asm_filename = ARGV[0]

unless is_readable?(asm_filename)
	abort("#{asm_filename} not found or is unreadable")
end

File.open(asm_filename) do |asm_file|
	File.open(hack_filename(asm_filename), 'w') do |hack_file|
		assembler = Assembler.new(asm_file, hack_file)
		assembler.assemble!
	end
end 
