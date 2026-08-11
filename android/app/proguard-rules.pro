# Room resolves generated database implementations through reflection. Keep
# their no-argument constructors so R8 cannot remove them in release builds.
-keep class * extends androidx.room.RoomDatabase {
    <init>();
}
