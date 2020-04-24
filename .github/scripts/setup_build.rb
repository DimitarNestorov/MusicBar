require 'xcodeproj'

require_relative 'get_versions_from_ref.rb'

open('Configuration/Config.xcconfig', 'w') { |f|
	f.puts "SENTRY_DSN = #{ENV['SENTRY_DSN']}"
}

versions = get_versions_from_ref ENV['GIT_REF']

project_path = 'MusicBar.xcodeproj'
project = Xcodeproj::Project.open(project_path)
project.targets.each do |target|
	target.build_configurations.each do |config|
		config.build_settings['MARKETING_VERSION'] = versions[:marketing_version]
		config.build_settings['CURRENT_PROJECT_VERSION'] = versions[:build_version]
	end
end

project.save()
