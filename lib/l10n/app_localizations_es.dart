// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appName => 'D-helper — Plataforma de entrega';

  @override
  String get deliveryPlatform => 'Plataforma de entrega';

  @override
  String get controlPanel => 'Panel de control';

  @override
  String get login => 'Iniciar Sesión';

  @override
  String get enterBtn => 'Entrar';

  @override
  String get signInWithGoogle => 'Iniciar sesión con Google';

  @override
  String get welcome => 'Bienvenido de nuevo';

  @override
  String get logout => 'Cerrar Sesión';

  @override
  String get logoutTitle => 'Cerrar sesión';

  @override
  String get logoutConfirm => '¿Seguro que quieres salir?';

  @override
  String get settings => 'Configuración';

  @override
  String get language => 'Idioma';

  @override
  String get profile => 'Perfil';

  @override
  String get demoAccount => 'Cuenta demo';

  @override
  String get email => 'Email';

  @override
  String get passwordField => 'Contraseña';

  @override
  String get forgotPassword => '¿Olvidaste la contraseña?';

  @override
  String get recoverPassword => 'Recuperar contraseña';

  @override
  String get enterEmail => 'Introduce tu email';

  @override
  String get codeWillBeSent => 'Te enviaremos un código de verificación.';

  @override
  String get sendCode => 'Enviar código';

  @override
  String get enterCode => 'Introduce el código';

  @override
  String codeSentTo(String email) {
    return 'Código enviado a $email';
  }

  @override
  String get demoMode => 'Modo demo';

  @override
  String get yourCode => 'Tu código:';

  @override
  String get sixDigitCode => 'Código de 6 dígitos';

  @override
  String get verifyCode => 'Verificar';

  @override
  String get choosePassword => 'Elige una contraseña segura.';

  @override
  String get newPassword => 'Nueva contraseña';

  @override
  String get confirmPassword => 'Confirmar contraseña';

  @override
  String get savePassword => 'Guardar contraseña';

  @override
  String get passwordUpdated => 'Contraseña actualizada ✓';

  @override
  String get passwordsDontMatch => 'Las contraseñas no coinciden';

  @override
  String get minPassword => 'Mínimo 6 caracteres';

  @override
  String get fillAllFields => 'Rellena todos los campos';

  @override
  String get emailNotFound => 'Email no encontrado';

  @override
  String get wrongCode => 'Código incorrecto';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get today => 'Hoy';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get thisYear => 'Este año';

  @override
  String get totalOrders => 'Pedidos totales';

  @override
  String get fromCalls => 'De llamadas';

  @override
  String get earnings => 'Ingresos';

  @override
  String get avgDeliveryTime => 'Tiempo medio';

  @override
  String get perDelivery => 'por entrega';

  @override
  String get avgPerOrder => 'Promedio / pedido';

  @override
  String get ordersLast7Days => 'Últimos 7 días';

  @override
  String get cashVsCard => 'Efectivo vs Tarjeta';

  @override
  String get inProgress => 'En curso';

  @override
  String get callLabel => 'Llamada';

  @override
  String get orders => 'Pedidos';

  @override
  String get newOrder => 'Nuevo Pedido';

  @override
  String get noOrdersYet => 'No hay pedidos aún';

  @override
  String get createOrder => 'Crear Pedido';

  @override
  String get customerName => 'Nombre del Cliente';

  @override
  String get phoneNumber => 'Número de Teléfono';

  @override
  String get deliveryAddress => 'Dirección de Entrega';

  @override
  String get foodItems => 'Artículos de Comida';

  @override
  String get addItem => 'Agregar Artículo';

  @override
  String get removeItem => 'Eliminar';

  @override
  String get itemName => 'Nombre del Artículo';

  @override
  String get quantity => 'Cantidad';

  @override
  String get price => 'Precio';

  @override
  String get paymentType => 'Tipo de Pago';

  @override
  String get cash => 'Efectivo';

  @override
  String get card => 'Tarjeta';

  @override
  String get online => 'En línea';

  @override
  String get submitOrder => 'Enviar Pedido';

  @override
  String get cancel => 'Cancelar';

  @override
  String get confirm => 'Confirmar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get loading => 'Cargando...';

  @override
  String get error => 'Ocurrió un error';

  @override
  String get orderStatus => 'Estado';

  @override
  String get pending => 'Pendiente';

  @override
  String get accepted => 'Aceptado';

  @override
  String get preparing => 'Preparando';

  @override
  String get ready => 'Listo';

  @override
  String get pickedUp => 'Recogido';

  @override
  String get delivered => 'Entregado';

  @override
  String get rejected => 'Rechazado';

  @override
  String get all => 'Todos';

  @override
  String get orderDetails => 'Detalles del Pedido';

  @override
  String get orderCreated => 'Pedido creado exitosamente';

  @override
  String get addAtLeastOneItem => 'Agrega al menos un artículo';

  @override
  String get required => 'Requerido';

  @override
  String get mapTab => 'Mapa';

  @override
  String get driversTab => 'Repartidores';

  @override
  String get restaurantsTab => 'Restaurantes';

  @override
  String get addDriver => 'Añadir repartidor';

  @override
  String get addRestaurant => 'Añadir restaurante';

  @override
  String get noDrivers => 'No hay repartidores';

  @override
  String get noRestaurants => 'No hay restaurantes';

  @override
  String get addFirstHint => 'Pulsa + para añadir uno';

  @override
  String get fullName => 'Nombre completo';

  @override
  String get vehicleType => 'Vehículo';

  @override
  String get motorcycle => 'Moto';

  @override
  String get car => 'Coche';

  @override
  String get bike => 'Bicicleta';

  @override
  String get onlineLabel => 'En línea';

  @override
  String get offlineLabel => 'Desconectado';

  @override
  String get deleteDriverTitle => 'Eliminar repartidor';

  @override
  String get deleteRestaurantTitle => 'Eliminar restaurante';

  @override
  String confirmDelete(String name) {
    return '¿Eliminar a $name?';
  }

  @override
  String get restaurantLabel => 'Restaurante';

  @override
  String get restaurantName => 'Nombre del restaurante';

  @override
  String get restaurantAddress => 'Dirección';

  @override
  String totalItems(int count) {
    return '$count artículos';
  }
}
