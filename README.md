# Rollover Application
This application is supposed to pull down all ReCharge subs and orders for updating in batches for the next month, and to that end also pull down all Shopify products, variants, collects, custom_collects, and selected metafields.

### To Do List
- [x] Wire up basics of getting ReCharge Subscriptions
- [ ] Get all ReCharge Active Subs from rake task and also job from rails front end app (Controller etc)
- [ ] Create db migrations and models to save all appropriate subscription information including saving product_collection as extra field in subscription model.
- [ ] Save all ReCharge subs (and sub_collection_sizes tables) in Database.
- [ ] Pull down and save all Shopify information, including metafields using code from alternate_tags table script.
- [ ] Create job/rake task/service and front end (Controller) to configure update information for singleton updates (only one set of product_collections: Example Balanced Beige) and corresponding (optional) size breaks. This includes models, migrations, and auto configuring from data (we can use some of Ghost Allocation here)
- [ ] Create job/rake task/service etc as above for selecting eligble subscriptions (with mark saved so we don't process the same subs twice!) including date ranges and size ranges and the like.
- [ ] Create an update service and associated other jobs/models/tasks etc. using Bulk Update if possible to update subs quickly with configured information (collections etc, size breaks in inventory, etc.). This should produce an export CSV emailed/pushed to S3 with what has been updated.
- [ ] Create a reporting model to show all remaining ReCharge Subs and Orders that are for next month still unassigned.