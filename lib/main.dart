import 'package:flutter/material.dart';
import 'package:provider_add_listener/success_page.dart';

import 'app_provider.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChangeNotifierProvider(
          create: (_) => AppProvider(), child: const HomePage()),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: const Scaffold(
        body: Content(),
      ),
    );
  }
}

class Content extends StatefulWidget {
  const Content({Key? key}) : super(key: key);
  @override
  State<Content> createState() => _ContentState();
}

class _ContentState extends State<Content> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AutovalidateMode _autovalidateMode = AutovalidateMode.disabled;
  String? searchTerm;

  void submit() async {
    setState(() {
      _autovalidateMode = AutovalidateMode.always;
    });

    final form = _formKey.currentState;

    if (form == null || !form.validate()) return;

    form.save();

    await context.read<AppProvider>().search(searchTerm!);
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => const SuccessPage(),
    //   ),
    // );
    // showDialog(
    //   context: context,
    //   builder: (_) => const AlertDialog(
    //     content: Text('Something went wrong'),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<AppProvider>().state;
//! Navigate or showDialog in build method is dangerous
//! the app may build serveral times
//! so below implement is not recommended
    if (appState == AppState.success) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const SuccessPage(),
          ),
        );
      });
    } else if (appState == AppState.error) {
      WidgetsBinding.instance!.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => const AlertDialog(
            content: Text('Something went wrong'),
          ),
        );
      });
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Form(
          autovalidateMode: _autovalidateMode,
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                autofocus: true,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                  label: Text('Search'),
                ),
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Search term is required';
                  }
                  return null;
                },
                onSaved: (String? value) {
                  searchTerm = value;
                },
              ),
              const SizedBox(
                height: 16.0,
              ),
              ElevatedButton(
                onPressed: appState == AppState.loading ? null : submit,
                child: Text(
                  appState == AppState.loading ? 'Searching...' : 'Search',
                  style: Theme.of(context).textTheme.headline5,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
