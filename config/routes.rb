
{
    "get" => {
        "/" => 'Controller#index',
        /^([a-z]+)$/ => '$1#index',
        /^([a-z]+)\/([a-z]+)$/ => '$1#$2'
    }
}
