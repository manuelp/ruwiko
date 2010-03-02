require 'wiki_creole'
require 'erb'

TITLE = "RuWiKo"
SUBTITLE = "A simple static wiki compiler."
HTML_DIR = "html"
WIKI_DIR = "wiki"

# Delete recursively the compile directory
def delete_dir dir_name
  puts "Deleting #{dir_name}..."
  files = Dir.entries(HTML_DIR)
  files.delete(".")
  files.delete("..")
  files.each {|file| File.delete(File.join(HTML_DIR, file))}
  Dir.delete(HTML_DIR)
end

def copy_css(data_dir, compile_dir)
  files = Dir.glob("#{data_dir}#{File::SEPARATOR}*.css")
  files.each {|file| file.sub!(/#{data_dir}#{File::SEPARATOR}/, '')}
  
  files.each do |file|
    in_file = File.open("#{data_dir}#{File::SEPARATOR}#{file}", 'r')
    out_file = File.open("#{compile_dir}#{File::SEPARATOR}#{file}", 'w')
    out_file.write(in_file.read)
    in_file.close
    out_file.close
  end
end

def correct_links(html)
  html.gsub!(/href=".*"/) {|match| match.chop.concat(".html\"") }
end

# Compile with WikiCreole every *.wiki file in the current directory 
# and place the compiled files in the compile_dir directory.
def compile_wiki_file(filename, wiki_dir, compile_dir)
  File.open(File.join(wiki_dir, filename)) do |file|
    wiki_file = file.read
    File.open(File.join(HTML_DIR, filename.sub(/\.wiki$/, "").concat(".html")), 'w') do |out_file|
      content = WikiCreole.creole_parse(wiki_file)
      html_file = ''
      File.open(File.join('data', 'default.html')) {|file| html_file = file.read}
      
      erb = ERB.new(html_file)
      html_file = erb.result(binding)
      
      correct_links(html_file)
      
      out_file.puts(html_file)
    end
  end
end

#### MAIN ####

delete_dir(HTML_DIR) if Dir.exists?(HTML_DIR)
Dir.mkdir(HTML_DIR)
copy_css('data', HTML_DIR)

# For each *.wiki file, compile it
dir = Dir.new('wiki')
dir.each do |file| 
  if file =~ /.*wiki$/
    puts "Compiling #{file} -> #{HTML_DIR}"
    compile_wiki_file(file, WIKI_DIR, HTML_DIR)
  end
end
