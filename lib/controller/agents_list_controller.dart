import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class AgentsListController extends GetxController {
  RxList<String> agentsProfileList = [
    Assets.images.agents1.path,
    Assets.images.agents2.path,
    Assets.images.agents3.path,
    Assets.images.agents4.path,
    Assets.images.agents5.path,
    Assets.images.agents6.path,
  ].obs;

  RxList<String> agentsNameList = [
    AppString.claudeAnderson,
    AppString.gerardShields,
    AppString.mattMorissette,
    AppString.eugeneConnelly,
    AppString.terrenceMedhurst,
    AppString.pennyRoberts,
  ].obs;

  RxList<String> agentsNumberList = [
    AppString.claudeAndersonNumber,
    AppString.gerardShieldsNumber,
    AppString.mattMorissetteNumber,
    AppString.eugeneConnellyNumber,
    AppString.terrenceMedhurstNumber,
    AppString.pennyRobertsNumber,
  ].obs;

  RxList<String> agentsPropertyList = [
    AppString.propertiesList3,
    AppString.propertiesList2,
    AppString.propertiesList3,
    AppString.propertiesList2,
    AppString.propertiesList5,
    AppString.propertiesList6,
  ].obs;

  RxList<String> agentsRatingList = [
    AppString.rating45,
    AppString.rating35,
    AppString.rating35,
    AppString.rating41,
    AppString.rating43,
    AppString.rating32,
  ].obs;
}
