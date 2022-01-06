import 'package:alquipet_front/models/http/get_filtered_listings_paginated_response.dart';
import 'package:alquipet_front/providers/listing_provider.dart';
import 'package:alquipet_front/ui/buttons/custom_outlined_button.dart';
import 'package:alquipet_front/ui/layouts/dashboard_layout.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ListingPage extends StatefulWidget {
  const ListingPage({Key? key}) : super(key: key);

  @override
  State<ListingPage> createState() => _ListingPageState();
}

class _ListingPageState extends State<ListingPage> {
  late String? id;
  late ListingProvider listingProvider;
  bool listingRecibedByParams = true;

  @override
  void initState() {
    listingProvider = Get.find<ListingProvider>();

    id = Get.parameters["id"];
    print("ID: $id");

    if (Get.arguments == null) {
      ///SI NO HAY ARGUMENTOS PASADOS DESDE LA RUTA ANTERIOR ES QUE SE HA ACCEDIDO PONIENDO LA URL EN EL NAVEGADOR
      listingRecibedByParams = false;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DashboardLayout(
      child: listingRecibedByParams == true
          ? ListView(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              children: const <Widget>[
                _ListingPageContent(),
              ],
            )
          : FutureBuilder<dynamic>(
              future: listingProvider.getListingById(id!),
              builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: const <Widget>[
                        Center(
                          child: CircularProgressIndicator(),
                        )
                      ],
                    ),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Center(
                      child: ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              const Text(
                                'Ha sucedido algo inesperado',
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              CustomOutlinedButton(
                                onPressed: () async {
                                  await listingProvider.getListingById(id!);
                                  setState(() {});
                                },
                                text: "Volver a intentar",
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasData) {
                    return ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: const <Widget>[
                        _ListingPageContent(),
                      ],
                    );
                  } else {
                    return Center(
                      child: ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children: const <Widget>[
                          Center(
                            child: Text(
                              'No hay datos que mostrar',
                            ),
                          )
                        ],
                      ),
                    );
                  }
                } else {
                  return Center(
                    child: ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: <Widget>[
                        Center(
                          child: Text(
                            'State: ${snapshot.connectionState}',
                          ),
                        )
                      ],
                    ),
                  );
                }
              },
            ),
    );
  }
}

class _ListingPageContent extends StatelessWidget {
  const _ListingPageContent({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Get.arguments == null) {
      final ListingProvider listingProvider = Get.find<ListingProvider>();
      return Hero(
        // transitionOnUserGestures: true,
        tag: listingProvider.getListingByIdResponse.listing.uid,
        child: Card(
          child:
              Text(listingProvider.getListingByIdResponse.listing.toString()),
        ),
      );
    } else {
      final Result listing = Get.arguments;
      return Hero(
        // transitionOnUserGestures: true,
        tag: listing.uid,
        child: Card(
          child: Text(
            listing.toString(),
          ),
        ),
      );
    }
  }
}
