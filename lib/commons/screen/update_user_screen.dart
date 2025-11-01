import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:merrymakin/commons/models/user.dart';
import 'package:merrymakin/commons/service/image_service.dart';

import 'package:merrymakin/commons/service/user_service.dart';
import 'package:merrymakin/commons/utils/constants.dart';
import 'package:merrymakin/commons/widgets/pro_list_view.dart';
import 'package:merrymakin/commons/widgets/pro_scaffold.dart';
import 'package:merrymakin/commons/widgets/pro_text.dart';
import 'package:merrymakin/commons/widgets/pro_text_field.dart';
import 'package:merrymakin/config/router.dart';
import 'package:merrymakin/factory/app_factory.dart';

import '../providers/user_provider.dart';
import '../service/cookie_service.dart';
import '../widgets/pro_user_avatar.dart';

class AddOrEditUser extends ConsumerStatefulWidget {
  final String sprylyService;
  final CookiesService cookiesService;
  final UserService userService;
  final ImageService imageService;
  AddOrEditUser({
    super.key,
    required this.sprylyService,
    required this.cookiesService,
    required this.userService,
    required this.imageService,
  });

  @override
  ConsumerState<AddOrEditUser> createState() => _AddOrEditUserState();
}

class _AddOrEditUserState extends ConsumerState<AddOrEditUser> {
  late User user;
  late Future<List<dynamic>> _future;
  final _formKey = GlobalKey<FormState>();
  final UserService userService = AppFactory().userService;

  @override
  void initState() {
    super.initState();
    _future = Future.value([widget.cookiesService.currentUser]);
  }

  void _submitData(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      userService.updateUser(user).then((dbReturnedUser) {
        if (dbReturnedUser != null) {
          ref.read(userProvider.notifier).login(dbReturnedUser);
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: ProText("Information updated")));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: ProText(
                  "Could not update user information. Please try again later.")));
        }
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          AppRouter.goHome(context);
        }
      });
    }
  }

  String? validateNameField(String fieldName, String? text) {
    if (text == null ||
        text.isEmpty ||
        text.trim().length <= 2 ||
        text.trim().length > 50) {
      return '${fieldName} must be between 2 and 50 characters';
    }
    return null;
  }

  String? validateDescriptionField(String? text) {
    if (text != null &&
        text.isNotEmpty &&
        text.trim().length <= 2 &&
        text.trim().length > 100) {
      return 'Description must be between 2 and 100 characters';
    }
    return null;
  }

  Widget _buildUserEditSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ProUserAvatar(
              user: user,
              radius: 60,
              canEdit: true,
              imageService: widget.imageService,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ),
        const SizedBox(height: generalAppLevelPadding * 2),
        ProText("Preferred first name"),
        const SizedBox(height: 8),
        ProTextField(
          initialValue: user.getFirstName(),
          onValidationCallback: (value) =>
              validateNameField('Preferred first name', value),
          onChanged: (value) {
            user.givenName = value;
          },
          onSaved: (value) {
            user.givenName = value.toString().trim();
          },
          hintText: 'Preferred first name',
        ),
        const SizedBox(height: 16),
        ProText("Last name"),
        const SizedBox(height: 8),
        ProTextField(
          initialValue: user.getLastName(),
          onValidationCallback: (value) =>
              validateNameField('Last name', value),
          onChanged: (value) {
            user.familyName = value;
          },
          onSaved: (value) {
            user.familyName = value.toString().trim();
          },
          hintText: 'Last name',
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget buildFormWidget(
    BuildContext context,
  ) {
    return ProScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            AppRouter.goHome(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => _submitData(context),
            child: const ProText(
              "Save",
            ),
          ),
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        double height = constraints.maxHeight;
        return Padding(
          padding: const EdgeInsets.only(
              right: generalAppLevelPadding * 2,
              left: generalAppLevelPadding * 2),
          child: Form(
              key: _formKey,
              child: ProListView(height: height, listItems: [
                const SizedBox(
                  height: generalAppLevelPadding / 2,
                ),
                _buildUserEditSection(),
                const SizedBox(height: generalAppLevelPadding),
                const SizedBox(height: generalAppLevelPadding * 10),
              ])),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if ((snapshot.connectionState == ConnectionState.waiting ||
              snapshot.data == null)) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.data != null &&
              snapshot.data!.isNotEmpty &&
              snapshot.data![0] != null) {
            user = snapshot.data![0];
          }

          return buildFormWidget(context);
        });
  }
}
