require 'osaka'

describe "Launch Services (wrapper around lsregister)" do

  before (:each) do
    @dumped_registry = <<-END_OF_DUMP
Checking data integrity......done.
Status: Database is seeded.
Status: Preferences are loaded.
--------------------------------------------------------------------------------
bundle	id:            54064
	path:          /Applications/TextMate.app
	name:          TextMate
	category:
	identifier:    com.macromates.TextMate.preview (0x8005c399)
	canonical id:  com.macromates.textmate.preview (0x8005c38f)
	version:       9515.0
	mod date:      2/24/2014 14:57:26
	reg date:      3/7/2014 13:22:06
	type code:     'APPL'
	creator code:  'avin'
	sys version:   10.7
	exec sdk ver:  10.8
	exec os ver:   10.7
	flags:         relative-icon-path  wildcard
	item flags:    container  package  application  extension-hidden  native-app  scriptable  x86_64
	hi res:        is-capabile  user-can-change
	app nap:       is-capabile  user-can-change
	icon:          Contents/Resources/TextMate.icns
	executable:    Contents/MacOS/TextMate
	inode:         32052233
	exec inode:    53967831
	container id:  32
	library:       Contents/Library/
	library items: QuickLook/TextMateQL.qlgenerator/
	               ../PlugIns/Dialog.tmplugin/
	               ../PlugIns/Dialog2.tmplugin/
	--------------------------------------------------------
	type	id:            62684
		bindableKey:   91052
		generation:    20451
		uti:           com.macromates.textmate.snippet
		description:   TextMate Snippet
		flags:         exported  active  trusted
		icon:          Contents/Resources/TextMate Snippet.icns
		conforms to:   com.apple.property-list
		tags:          .tmsnippet
END_OF_DUMP
  end

  it "Can return a dump of the current database" do
   expect(Osaka::CommandRunner).to receive(:run).with("/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump").and_return(@dumped_registry)
   current_dump = Osaka::LaunchServices.dump
   expect(current_dump).to start_with("Checking data integrity......done.\nStatus: Database is seeded.\nStatus: Preferences are loaded.\n--------------------------------------------------------------------------------")
   expect(current_dump).to include("name:          TextMate")
  end

  it "Can retrieve a value based on the bundle name" do
    expect(Osaka::CommandRunner).to receive(:run).and_return(@dumped_registry)
    expect(Osaka::LaunchServices.retrieve("TextMate")[:id]).to eq "54064"
  end
end

