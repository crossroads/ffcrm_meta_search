require "fat_free_crm"

FatFreeCRM::Plugin.register(:crm_meta_search, self) do
          name "Meta Search"
        author "Ben Tillman"
       version "0.1"
   description "Meta Search integration for Fat Free CRM"
  dependencies :meta_search
end

require "crm_meta_search"
