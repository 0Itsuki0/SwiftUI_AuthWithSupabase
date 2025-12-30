#  SwiftUI: Auth With Supabase

A demo of authentication with Supabase. Including sign up, sign in (password or password less), reset password, and etc. With Custom URL Scheme.
watch for changes.

For more details, please refer to my blog [SwiftUI: Auth With Supabase](https://medium.com/@itsuki.enjoy/swiftui-auth-with-supabase-6c616e0e0ffe)

## Set up
1. Go to [database.new](https://database.new/) and click on that New project button to create a new Supabase project.
2. Get API details (connection URL and publishable key) from the [project Connect dialog](https://supabase.com/dashboard/project/_?showConnect=true&connectTab=mobiles&framework=swift)
3. Set the configuration details in `Supabase.plist`.
4. Choose a bundle identifier. This will be used as the custom URL scheme for callbacks (redirect) URL sent to the email for sign up confirmation, magic link sign in, reset password and etc.
5. Add the custom URL scheme under the [Redirect URLs](https://supabase.com/dashboard/project/_/auth/url-configuration) list configuration. If we had `itsuki.enjoy.SupabaseAuth` above, we will add `itsuki.enjoy.SupabaseAuth://**` here. 



## Demo

![](./demo.gif)

