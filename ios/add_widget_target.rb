#!/usr/bin/env ruby
# Adds the TimetableWidget WidgetKit extension target to Runner.xcodeproj and
# wires the App Group + embedding. Idempotent: removes a prior target first.
require 'xcodeproj'

PROJECT = File.join(__dir__, 'Runner.xcodeproj')
APP_ID = 'com.example.timetable'
WIDGET_NAME = 'TimetableWidget'
WIDGET_ID = "#{APP_ID}.#{WIDGET_NAME}"

project = Xcodeproj::Project.open(PROJECT)
runner = project.targets.find { |t| t.name == 'Runner' }
raise 'Runner target not found' unless runner

# --- Clean any previous attempt -------------------------------------------
project.targets.select { |t| t.name == WIDGET_NAME }.each do |t|
  t.remove_from_project
end
runner.dependencies.dup.each do |dep|
  dep.remove_from_project if dep.display_name == WIDGET_NAME
end
runner.copy_files_build_phases.select { |p| p.name == 'Embed Foundation Extensions' }.each(&:remove_from_project)
project.main_group.children.select { |g| g.respond_to?(:display_name) && g.display_name == WIDGET_NAME }.each(&:remove_from_project)

# --- Create the extension target ------------------------------------------
widget = project.new_target(:app_extension, WIDGET_NAME, :ios, '14.0')

# Source + Info.plist group
group = project.main_group.new_group(WIDGET_NAME, WIDGET_NAME)
swift_ref = group.new_reference('TimetableWidget.swift')
group.new_reference('Info.plist')
group.new_reference('TimetableWidget.entitlements')
widget.add_file_references([swift_ref])

# Build settings for every config
widget.build_configurations.each do |config|
  bs = config.build_settings
  bs['PRODUCT_BUNDLE_IDENTIFIER'] = WIDGET_ID
  bs['PRODUCT_NAME'] = '$(TARGET_NAME)'
  bs['INFOPLIST_FILE'] = 'TimetableWidget/Info.plist'
  bs['GENERATE_INFOPLIST_FILE'] = 'NO'
  bs['CODE_SIGN_ENTITLEMENTS'] = 'TimetableWidget/TimetableWidget.entitlements'
  bs['CODE_SIGN_STYLE'] = 'Automatic'
  bs['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
  bs['TARGETED_DEVICE_FAMILY'] = '1,2'
  bs['SWIFT_VERSION'] = '5.0'
  bs['CURRENT_PROJECT_VERSION'] = '1'
  bs['MARKETING_VERSION'] = '1.0'
  bs['SKIP_INSTALL'] = 'YES'
  bs['INFOPLIST_KEY_CFBundleDisplayName'] = 'Timetable'
  bs['LD_RUNPATH_SEARCH_PATHS'] =
    ['$(inherited)', '@executable_path/Frameworks', '@executable_path/../../Frameworks']
end

# --- Embed the extension into the app -------------------------------------
runner.add_dependency(widget)
embed = runner.new_copy_files_build_phase('Embed Foundation Extensions')
embed.symbol_dst_subfolder_spec = :plug_ins
build_file = embed.add_file_reference(widget.product_reference, true)
build_file.settings = { 'ATTRIBUTES' => ['RemoveHeadersOnCopy'] }

# --- App Group entitlements on the Runner app -----------------------------
runner_group = project.main_group['Runner']
runner_group.new_reference('Runner.entitlements') if runner_group
runner.build_configurations.each do |config|
  config.build_settings['CODE_SIGN_ENTITLEMENTS'] = 'Runner/Runner.entitlements'
end

project.save
puts "Added target #{WIDGET_NAME} (#{WIDGET_ID})."
puts "Targets now: #{project.targets.map(&:name).join(', ')}"
