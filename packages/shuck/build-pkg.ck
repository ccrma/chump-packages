@import "Chumpinate"

Package pkg("shuck");
pkg.authors(["Brendan Zelikman"]);
pkg.homepage("https://ccrma.stanford.edu/~brendan/shuck");
pkg.description("Structured Harmony in ChucK.");
pkg.license("MIT");
pkg.keywords(["scales", "chords", "voice leading", "structured", "harmony", "tonality"]);
pkg.generatePackageDefinition("./");

PackageVersion ver("shuck", "0.1.0");
ver.languageVersionMin("1.5.4.5");
ver.os("any");
ver.arch("all");
ver.addFile("src/note.ck");
ver.addFile("src/pose.ck");
ver.addFile("src/query.ck");
ver.addFile("src/regex.ck");
ver.addFile("src/scale.ck");
ver.addFile("src/test.ck");
ver.addFile("src/tree.ck");
ver.addFile("src/utils.ck");

ver.generateVersion("./", "shuck", "https://ccrma.stanford.edu/~brendan/shuck/shuck.zip");
ver.generateVersionDefinition("shuck", "./");