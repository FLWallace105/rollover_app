class ShopifyPullAllJob < ApplicationJob
  queue_as :shopify_all

  def perform(*args)
    puts "Starting pulling Shopify products"
    starting = Process.clock_gettime(Process::CLOCK_MONOTONIC)

    Shopify::EllieService.fetch
    Shopify::EllieCollectsService.fetch
    Shopify::EllieCustomCollectionsService.fetch

    ending = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    elapsed = ending - starting
    puts "Finished after: #{elapsed} seconds."
  end
end
