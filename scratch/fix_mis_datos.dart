import 'dart:io';

void main() {
  final file = File('c:/src/academia/lib/screens/pantalla_mis_datos.dart');
  var content = file.readAsStringSync();
  content = content.replaceAll(
    "import '../widgets/custom_snackbar.dart';", 
    "import '../widgets/custom_snackbar.dart';\nimport '../widgets/carnet_digital.dart';"
  );
  
  content = content.replaceAll(
    '''
                    CustomButton(
                      text: 'Guardar Cambios',
                      icon: LucideIcons.save,
                      onPressed: () {
                        CustomSnackbar.show(
                          context, 
                          message: 'Edición de datos simulada por ahora',
                          type: SnackbarType.info,
                        );
                      },
                    ),''',
    '''
                    CustomButton(
                      text: 'Guardar Cambios',
                      icon: LucideIcons.save,
                      onPressed: () {
                        CustomSnackbar.show(
                          context, 
                          message: 'Edición de datos simulada por ahora',
                          type: SnackbarType.info,
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Ver Carnet Digital (3D)',
                      icon: LucideIcons.scanFace,
                      backgroundColor: AppTheme.secondaryPurple,
                      onPressed: () {
                        showGeneralDialog(
                          context: context,
                          barrierDismissible: true,
                          barrierLabel: 'Cerrar',
                          barrierColor: Colors.black.withOpacity(0.8),
                          transitionDuration: const Duration(milliseconds: 400),
                          pageBuilder: (context, animation, secondaryAnimation) {
                            return ScaleTransition(
                              scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                              child: Center(
                                child: Material(
                                  color: Colors.transparent,
                                  child: CarnetDigital(
                                    nombre: user?.nombre ?? 'Usuario',
                                    rol: user?.rol ?? 'Estudiante',
                                    documento: user?.id.toString() ?? '123456789',
                                    programa: 'Ingeniería',
                                    telefono: '555-0123',
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),'''
  );
  file.writeAsStringSync(content);
}
