Jekyll::Hooks.register :posts, :post_render do |document|
  if document.output_ext == ".html"
    document.output = document.output.gsub(%r{(<div class="post-body">.*?</div>)}m) do |match|
      match.gsub(/<img(?![^>]*loading=)([^>]*?)>/) { "<img loading=\"lazy\"#{$1}>" }
    end
  end
end
