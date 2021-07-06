import 'package:flutter/material.dart';
import 'package:gwa_app/widgets/gradient_title_appbar.dart';
import 'package:gwa_app/widgets/markdown_viewer.dart';

class About extends StatelessWidget {
  const About({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: GradientTitleAppBar(
        context,
        title: 'About',
      ),
      backgroundColor: Theme.of(context).backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
          child: Material(
            color: Theme.of(context).primaryColor,
            elevation: 15.0,
            borderRadius: BorderRadius.circular(32.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: MarkdownViewer(
                text:
                    // FIXME: New Name Flag. How to Contribute Flag. How to Submit an Issue Flag.
                    """# {Name}
A browser for the GoneWildAudio subreddit.

![App Screenshot](https://via.placeholder.com/468x300?text=App+Screenshots+Here)

## The First GoneWildAudio Focused App
{Name} is the first GoneWildAudio focused app. It's built with Flutter and is open sourced.

It's currently available for Android, but since it's built with Flutter cross platform support is possible.
## Features
- GoneWildAudio Content Focused UI
- Tag Querying
- User Library
## Contributing

Be it patching, new code, feature request, ui designs and anything else (does not have to be coding related), contributions are always welcome!

See Contributions.md for what you can help with and how to get started.

Also, you can always vote on existing new feature requests or general app ideas that you'd like to see implemented!
See how in Contributions.md.
  
## Submitting Issues

You can submit a new issue here: {issue flag}.

### Guidelines
**Questions:** Try to define the question clearly.

**Bugs:** Try to define the bug clearly and provide steps to reproduce it.
If you can, providing screenshots from  the app will also be helpful.

  
## Roadmap

- Built In Audio Player

- IOS Support

- Library Lists Creation and Management

- Home Sections Creation Management

- Comments Support

- Pushshift Api Integration (maybe)

Please note that this roadmap is not set in stone and features could be removed (or added...).
""",
                inPopupCard: false,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
