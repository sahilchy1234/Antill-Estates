import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:antill_estates/configs/app_string.dart';
import 'package:antill_estates/gen/assets.gen.dart';

class EditCountryPickerController extends GetxController {
  TextEditingController searchController = TextEditingController();
  TextEditingController search2Controller = TextEditingController();

  RxInt selectedIndex = (18).obs;
  RxInt selected2Index = (18).obs;

  void selectCountry(int index) {
    selectedIndex.value = index;
  }

  void select2Country(int index) {
    selected2Index.value = index;
  }

  RxList<String> flagsImageList = [
    Assets.flags.af.path,
    Assets.flags.al.path,
    Assets.flags.ar.path,
    Assets.flags.au.path,
    Assets.flags.at.path,
    Assets.flags.bd.path,
    Assets.flags.be.path,
    Assets.flags.br.path,
    Assets.flags.ca.path,
    Assets.flags.cn.path,
    Assets.flags.co.path,
    Assets.flags.cz.path,
    Assets.flags.dk.path,
    Assets.flags.eg.path,
    Assets.flags.fi.path,
    Assets.flags.fr.path,
    Assets.flags.de.path,
    Assets.flags.gr.path,
    Assets.flags.india.path,
    Assets.flags.id.path,
    Assets.flags.ir.path,
    Assets.flags.it.path,
    Assets.flags.jp.path,
    Assets.flags.ke.path,
    Assets.flags.mx.path,
    Assets.flags.nl.path,
    Assets.flags.nz.path,
    Assets.flags.ng.path,
    Assets.flags.no.path,
    Assets.flags.pk.path,
    Assets.flags.pe.path,
    Assets.flags.ph.path,
    Assets.flags.pl.path,
    Assets.flags.pt.path,
    Assets.flags.ru.path,
    Assets.flags.sa.path,
    Assets.flags.za.path,
    Assets.flags.kr.path,
    Assets.flags.es.path,
    Assets.flags.se.path,
    Assets.flags.ch.path,
    Assets.flags.th.path,
    Assets.flags.tr.path,
    Assets.flags.ua.path,
    Assets.flags.gb.path,
    Assets.flags.us.path,
    Assets.flags.vn.path,
    Assets.flags.zw.path,
  ].obs;

  RxList<Map<String, String>> countries = [
    {
      AppString.namePicker: AppString.afghanistan,
      AppString.codeText: AppString.afghanistanCode,
    },
    {
      AppString.namePicker: AppString.albania,
      AppString.codeText: AppString.albaniaCode,
    },
    {
      AppString.namePicker: AppString.argentina,
      AppString.codeText: AppString.argentinaCode,
    },
    {
      AppString.namePicker: AppString.australia,
      AppString.codeText: AppString.australiaCode,
    },
    {
      AppString.namePicker: AppString.austria,
      AppString.codeText: AppString.austriaCode,
    },
    {
      AppString.namePicker: AppString.bangladesh,
      AppString.codeText: AppString.bangladeshCode,
    },
    {
      AppString.namePicker: AppString.belgium,
      AppString.codeText: AppString.belgiumCode,
    },
    {
      AppString.namePicker: AppString.brazil,
      AppString.codeText: AppString.brazilCode,
    },
    {
      AppString.namePicker: AppString.canada,
      AppString.codeText: AppString.canadaCode,
    },
    {
      AppString.namePicker: AppString.china,
      AppString.codeText: AppString.chinaCode,
    },
    {
      AppString.namePicker: AppString.colombia,
      AppString.codeText: AppString.colombiaCode,
    },
    {
      AppString.namePicker: AppString.czechRepublic,
      AppString.codeText: AppString.czechRepublicCode,
    },
    {
      AppString.namePicker: AppString.denmark,
      AppString.codeText: AppString.denmarkCode,
    },
    {
      AppString.namePicker: AppString.egypt,
      AppString.codeText: AppString.egyptCode,
    },
    {
      AppString.namePicker: AppString.finland,
      AppString.codeText: AppString.finlandCode,
    },
    {
      AppString.namePicker: AppString.france,
      AppString.codeText: AppString.franceCode,
    },
    {
      AppString.namePicker: AppString.germany,
      AppString.codeText: AppString.germanyCode,
    },
    {
      AppString.namePicker: AppString.greece,
      AppString.codeText: AppString.greeceCode,
    },
    {
      AppString.namePicker: AppString.india,
      AppString.codeText: AppString.countryCode,
    },
    {
      AppString.namePicker: AppString.indonesia,
      AppString.codeText: AppString.indonesiaCode,
    },
    {
      AppString.namePicker: AppString.iran,
      AppString.codeText: AppString.iranCode,
    },
    {
      AppString.namePicker: AppString.italy,
      AppString.codeText: AppString.italyCode,
    },
    {
      AppString.namePicker: AppString.japan,
      AppString.codeText: AppString.japanCode,
    },
    {
      AppString.namePicker: AppString.kenya,
      AppString.codeText: AppString.kenyaCode,
    },
    {
      AppString.namePicker: AppString.mexico,
      AppString.codeText: AppString.mexicoCode,
    },
    {
      AppString.namePicker: AppString.netherlands,
      AppString.codeText: AppString.netherlandsCode,
    },
    {
      AppString.namePicker: AppString.newZealand,
      AppString.codeText: AppString.newZealandCode,
    },
    {
      AppString.namePicker: AppString.nigeria,
      AppString.codeText: AppString.nigeriaCode,
    },
    {
      AppString.namePicker: AppString.norway,
      AppString.codeText: AppString.norwayCode,
    },
    {
      AppString.namePicker: AppString.pakistan,
      AppString.codeText: AppString.pakistanCode,
    },
    {
      AppString.namePicker: AppString.peru,
      AppString.codeText: AppString.peruCode,
    },
    {
      AppString.namePicker: AppString.philippines,
      AppString.codeText: AppString.philippinesCode,
    },
    {
      AppString.namePicker: AppString.poland,
      AppString.codeText: AppString.polandCode,
    },
    {
      AppString.namePicker: AppString.portugal,
      AppString.codeText: AppString.portugalCode,
    },
    {
      AppString.namePicker: AppString.russia,
      AppString.codeText: AppString.russiaCode,
    },
    {
      AppString.namePicker: AppString.saudiArabia,
      AppString.codeText: AppString.saudiArabiaCode,
    },
    {
      AppString.namePicker: AppString.southAfrica,
      AppString.codeText: AppString.southAfricaCode,
    },
    {
      AppString.namePicker: AppString.southKorea,
      AppString.codeText: AppString.southKoreaCode,
    },
    {
      AppString.namePicker: AppString.spain,
      AppString.codeText: AppString.spainCode,
    },
    {
      AppString.namePicker: AppString.sweden,
      AppString.codeText: AppString.swedenCode,
    },
    {
      AppString.namePicker: AppString.switzerland,
      AppString.codeText: AppString.switzerlandCode,
    },
    {
      AppString.namePicker: AppString.thailand,
      AppString.codeText: AppString.thailandCode,
    },
    {
      AppString.namePicker: AppString.turkey,
      AppString.codeText: AppString.turkeyCode,
    },
    {
      AppString.namePicker: AppString.ukraine,
      AppString.codeText: AppString.ukraineCode,
    },
    {
      AppString.namePicker: AppString.unitedKingdom,
      AppString.codeText: AppString.unitedKingdomCode,
    },
    {
      AppString.namePicker: AppString.unitedStates,
      AppString.codeText: AppString.unitedStatesCode,
    },
    {
      AppString.namePicker: AppString.vietnam,
      AppString.codeText: AppString.vietnamCode,
    },
    {
      AppString.namePicker: AppString.zimbabwe,
      AppString.codeText: AppString.zimbabweCode,
    },
  ].obs;

  @override
  void dispose() {
    super.dispose();
    searchController.clear();
    search2Controller.clear();
  }
}
