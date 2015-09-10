
{
  "get" => {
    /^([a-z]+)$/ => '$1#index',
    /^([a-z]+)\/([a-z]+)$/ => '$1#$2',
    // => 'Lean::Controller#index'
  }
}
