FactoryBot.define do
  factory :sync_job do
    account nil
    sync_start "2018-03-15 13:02:09"
    sync_end "2018-03-15 13:02:09"
    new_entries 1
    skipped_entries 1
    processed_entries 1
    info "MyText"
  end
end
