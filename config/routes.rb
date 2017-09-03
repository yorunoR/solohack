Rails.application.routes.draw do
    root to: 'events#check'

    get  'check'      => 'events#check'
    get  'check2'     => 'events#check2'

    post 'search'     => 'events#search'

    post 'follow'     => 'events#follow'

    post 'delete'     => 'events#delete'

    post 'users'      => 'events#users'
end
