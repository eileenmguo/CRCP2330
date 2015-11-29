#! /usr/bin/env ruby 

class Assembler
	def initialize(asm_file, hack_file)
		@asm_file = asm_file
		@hack_file = hack_file
	end

	def assemble!
		puts @asm_file.read
	end
end

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
