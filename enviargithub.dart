import 'dart:io';

void main() async {
  print('╔══════════════════════════════════════════════════╗');
  print('║       Asistente de Subida a GitHub (Dart)        ║');
  print('╚══════════════════════════════════════════════════╝\n');

  // 1. Ingresar el link del repositorio
  stdout.write('1. Ingresa el link del repositorio de GitHub (ej. https://github.com/usuario/repo.git):\n> ');
  String? repoUrl = stdin.readLineSync()?.trim();
  
  if (repoUrl == null || repoUrl.isEmpty) {
    print('❌ Error: Debes ingresar un link válido.');
    exit(1);
  }

  // 2. Ingresar el mensaje del commit
  stdout.write('\n2. Ingresa el mensaje del commit:\n> ');
  String? commitMessage = stdin.readLineSync()?.trim();
  
  if (commitMessage == null || commitMessage.isEmpty) {
    print('⚠️  Mensaje vacío. Se usará el mensaje por defecto: "Primer commit"');
    commitMessage = 'Primer commit';
  }

  // 3. Establecer la rama
  stdout.write('\n3. Ingresa el nombre de la rama (Presiona ENTER para usar "main" por defecto):\n> ');
  String? branchName = stdin.readLineSync()?.trim();
  
  if (branchName == null || branchName.isEmpty) {
    branchName = 'main';
    print('🌿 Se usará la rama default: "$branchName"');
  }

  print('\n🚀 Iniciando proceso para subir a GitHub...\n');

  // Ejecución consecutiva de comandos git
  await _ejecutarComando('git', ['init'], 'Inicializando git...');
  await _ejecutarComando('git', ['add', '.'], 'Agregando los archivos (git add .)...');
  await _ejecutarComando('git', ['commit', '-m', commitMessage], 'Haciendo commit...');
  await _ejecutarComando('git', ['branch', '-M', branchName], 'Estableciendo rama ($branchName)...');
  
  // Se remueve 'origin' por si ya existe e interfiere con el nuevo que agregaremos
  await Process.run('git', ['remote', 'remove', 'origin']);
  
  await _ejecutarComando('git', ['remote', 'add', 'origin', repoUrl], 'Agregando repositorio remoto...');
  
  print('\n⏳ Subiendo código a GitHub (esto puede tardar unos momentos)...');
  bool finalizadoConExito = await _ejecutarComando('git', ['push', '-u', 'origin', branchName], 'Haciendo push...');

  if (finalizadoConExito) {
    print('\n✅ ¡Repositorio subido a GitHub exitosamente! 🎉');
  } else {
    print('\n❌ Hubo un inconveniente al subir a GitHub. Revisa los errores mencionados arriba.');
  }
}

/// Función auxiliar para ejecutar el proceso en consola y manejar los posibles errores.
Future<bool> _ejecutarComando(String comando, List<String> argumentos, String mensaje) async {
  print('▶ $mensaje');
  try {
    var resultado = await Process.run(comando, argumentos);
    if (resultado.exitCode != 0) {
      // Ignorar errores triviales si nada nuevo a comitear
      if (argumentos.contains('commit') && resultado.stdout.toString().contains('nothing to commit')) {
        print('   ℹ️ No hay archivos nuevos para hacer commit.');
        return true;
      }

      print('   ❌ Error ejecutando: $comando ${argumentos.join(' ')}');
      print('      Mensaje del sistema: ${resultado.stderr.toString().trim()}');
      return false;
    }
    return true;
  } catch (e) {
    print('   ❌ Ocurrió una excepción al ejecutar: $e');
    return false;
  }
}