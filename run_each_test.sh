UNIT_TESTS+=" ./spec/calculator_spec.rb" 
UNIT_TESTS+=" ./spec/defaultssystem_spec.rb" 
UNIT_TESTS+=" ./spec/keynote_flows_spec.rb" 
UNIT_TESTS+=" ./spec/keynote_spec.rb" 
UNIT_TESTS+=" ./spec/launchservices_spec.rb" 
UNIT_TESTS+=" ./spec/location_spec.rb" 
UNIT_TESTS+=" ./spec/mailmergeflow_spec.rb" 
UNIT_TESTS+=" ./spec/numbers_spec.rb" 
UNIT_TESTS+=" ./spec/osakaexpectations_spec.rb" 
# UNIT_TESTS+=" ./spec/pages_spec.rb" 
UNIT_TESTS+=" ./spec/preview_spec.rb" 
UNIT_TESTS+=" ./spec/remotecontrol_spec.rb" 
UNIT_TESTS+=" ./spec/scriptrunner_spec.rb" 
UNIT_TESTS+=" ./spec/textedit_spec.rb" 
UNIT_TESTS+=" ./spec/typicalapplication_spec.rb" 
UNIT_TESTS+=" ./spec/typicalfinderdialog_spec.rb" 
UNIT_TESTS+=" ./spec/typicalopendialog_spec.rb" 
UNIT_TESTS+=" ./spec/typicalprintdialog_spec.rb" 
UNIT_TESTS+=" ./spec/typicalsavedialog_spec.rb"
 
INTEGRATION_TESTS+=" ./spec/integration_calculator_spec.rb" 
INTEGRATION_TESTS+=" ./spec/integration_keynote_spec.rb" 
INTEGRATION_TESTS+=" ./spec/integration_numbers_spec.rb" 
INTEGRATION_TESTS+=" ./spec/integration_preview_spec.rb" 
INTEGRATION_TESTS+=" ./spec/integration_textedit_spec.rb" 
## INTEGRATION_TESTS+=" ./spec/integration_pages_numbers_mail_merge_spec.rb" 

export LANG=en_US.UTF-8

if [ "$1" == "u" ] ; then
  ruby -S rspec $UNIT_TESTS
  
elif [ "$1" == "i" ] ; then
  ruby -S rspec $INTEGRATION_TESTS
else
  ruby -S rspec $UNIT_TESTS
  ruby -S rspec $INTEGRATION_TESTS
fi


