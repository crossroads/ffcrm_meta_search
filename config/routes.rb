FatFreeCRM::Application.routes.draw do
  %w(accounts campaigns contacts leads opportunities tasks).each do |controller|
    match "/#{controller}/meta_search" => "#{controller}#meta_search", :as => "#{controller}_meta_search"
  end
end
