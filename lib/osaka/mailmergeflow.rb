
module CommonFlows
  
  def self.number_and_pages_mail_merge(numbers_file, pages_file, output_file)
    numbers = Osaka::Numbers.new
    pages = Osaka::Pages.new
    
    numbers.open(numbers_file)
    yield numbers if block_given?
    numbers.save
    
    pages.open(pages_file)
    pages.mail_merge_to_pdf(output_file)
    
    numbers.close(:dont_save)
    pages.close(:dont_save)

    numbers.quit(:dont_save)
    pages.quit(:dont_save)
    
  end
end