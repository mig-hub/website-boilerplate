require 'populate_me/admin'

class Admin < PopulateMe::Admin

  set :root, ::File.expand_path('../..', __FILE__)

  set :cerberus, {company_name: 'Company'}

  set :menu, [
    # ['Details', '/admin/form/details/unique'],
    # ['Products', '/admin/list/product']
  ]

end

