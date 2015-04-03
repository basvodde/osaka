
module CommonFlows

  def self.number_and_pages_mail_merge(numbers_file, pages_file, output_file)

    if block_given?
      Osaka::Numbers.create_document(numbers_file) { |numbers|
        yield numbers
      }
    end

    pages = Osaka::Pages.new
    pages.open(pages_file)
    pages.set_mail_merge_document(numbers_file)
    pages.mail_merge_to_pdf(output_file)
    pages.close(:dont_save)
    pages.quit(:dont_save)
  end
end
