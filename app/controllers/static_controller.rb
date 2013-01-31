class StaticController < ApplicationController
  caches_page :about, :contact, :faq, :glossary, :submit, :terms, :guide

  def about
  end

  def contact
  end

  def download
    respond_to do |format|
      format.html
      format.csv { send_file "#{Rails.root}/public/system/download_arrangements.csv", type: 'text/csv; charset=utf-8; header=present' }
    end
  end

  def faq
  end

  def glossary
  end

  def submit
  end

  def terms
  end

  def guide
  end
end
