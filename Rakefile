# This rakefile:
# -compiles coffee scripts
# -compiles templates
# -compiles stylus styles
# -eventually cleans up web to be a dist only thinger

require 'rake'

myDir = Dir.pwd

cmdPprefix = ""
if ENV['OS'] != nil
	if ENV['OS']['Windows'] != nil
		cmdPrefix = "powershell "
	end
end

task :updateCoffeeIgnore do
	system "./updateCoffeeIgnore.sh"
end

task :coffee, :watch do |t, args|
	Rake::Task["compileCoffee"].invoke args[:watch]
end

task :templates => [:compileTpls] do
end

task :compileTpls, :pretty do |t, args|
	FileList[myDir + "/src/ui/**/res/templates"].each do |filename|
		pretty = args[:pretty]
		puts "Processing: #{filename}"
		compiledTemplates = '''
		define(["vendor/amd/Handlebars"], function(Handlebars) {
			return {
		'''

		first = true
		FileList["#{filename}/*.bars"].each do |fname|
			pipe = IO.popen("handlebars -s #{fname}")
			result = pipe.readlines
			pipe.close

			joined = result.join
			if not pretty
				joined = joined.gsub(/\\r\\n|\n|\\n/, "");
			end
			templateFileName = File.basename(fname, ".bars");

			if first
				compiledTemplates += "\n\"#{templateFileName}\": Handlebars.template(#{joined})"
				first = false
			else
				compiledTemplates += ",\n\"#{templateFileName}\": Handlebars.template(#{joined})"
			end
  		end

  		destination = filename.sub("/src/ui/", "/web/scripts/ui/").sub("/res/templates", "")
  		puts "#{destination}/Templates.js"
  		File.open("#{destination}/Templates.js", 'w') {|f|
  			f.write(compiledTemplates)
  			f.write("\n}});");
  		}
	end
end

task :compileStylus do
end

task :buildVendor do
	system "#{cmdPrefix}rm web/scripts/vendor/vendor-built.js"
	system "#{cmdPrefix}rm web/scripts/vendor/temp/*"
	FileList["web/scripts/vendor/*.js"].each do |fname|
		system %{uglifyjs #{fname} > web/scripts/vendor/temp/#{File.basename(fname, ".js")}.min.js}
	end

	if cmdPrefix != ""
		system %{type web\\scripts\\vendor\\temp\\* >> web\\scripts\\vendor\\vendor-built.js}
	else
		system %{cat web/scripts/vendor/temp/* >> web/scripts/vendor/vendor-built.js}
	end
end

task :compileCoffee, :watch do |t,args|
	watch = ""
	if args[:watch]
		watch = "--watch"
	end

	system %{coffee #{watch} -b --compile --output web/scripts/ src/}
end

task :zipForLocal => [:compileCoffee, :compileTpls] do
	system "tar -c web > Strut.tar"
	system "gzip Strut.tar"
end

task :docs do
	system %{yuidoc web/scripts -o docs}
end

task :refactor, :source, :destination do |t, args|
	source = args[:source]
	destination = args[:destination]

	if !destination
		puts "usage: rake refactor[source,destination]"
		exit
	end

	FileList["./**/*.js"].each do |fname|
		#puts fname
		pipe = IO.popen("amdRefactor #{source} < #{fname}")
		result = pipe.readlines
		pipe.close

		if result.length > 0
			# line col_start col_end
			importLoc = result[0].split(",")
			line = Integer(importLoc[0]) - 1
			colStart = Integer(importLoc[1]) - 1
			colEnd = Integer(importLoc[2])

			lines = File.readlines(fname);
			theLine = lines[line]
			theLine = 
				"#{theLine[0..colStart]}#{destination}#{theLine[colEnd..theLine.length]}"

			lines[line] = theLine

			puts "Refactoring: #{fname}"
			File.open(fname, 'w') { |f| f << lines }
			#puts lines
		end
	end
end

task :showDeps, :package do |t, args|
	myPkg = args[:package]

	if !myPkg
		puts "usage: rake showDeps[package]"
		exit
	end

	FileList["web/scripts/#{myPkg}/**/*.js"].each do |fname|
		pipe = IO.popen("amdDeps #{myPkg} < #{fname}")
		result = pipe.readlines
		pipe.close

		if result.length > 0
			puts result
		end
	end
end