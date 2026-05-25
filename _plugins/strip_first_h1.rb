Jekyll::Hooks.register :posts, :post_render do |document|
  if document.output_ext == ".html"
    document.output = document.output.sub(%r{<div class="post-body">\s*<h1[^>]*>.*?</h1>\s*}, '<div class="post-body">')
  end
end
