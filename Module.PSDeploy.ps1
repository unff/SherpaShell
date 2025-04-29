Deploy Module {
    By PSGalleryModule {
        FromSource Build\SherpaShell
        To PSGallery
        WithOptions @{
            ApiKey = $ENV:PSGalleryKey
        }
    }
}