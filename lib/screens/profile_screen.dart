import 'package:flutter/material.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _usernameController;
  late TextEditingController _emailController;

  UserModel? _user;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _usernameController = TextEditingController();
    _emailController = TextEditingController();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final currentUid = _authService.currentUser?.uid;
    if (currentUid == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Sessão expirada. Por favor, faça login novamente.';
      });
      return;
    }

    try {
      final user = await _authService.getUserProfile(currentUid);
      if (user == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Dados de perfil não encontrado';
        });
        return;
      }

      if (!mounted) return;
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _usernameController.text = user.username;
        _emailController.text = user.email;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar perfil: $e';
      });
    }
  }

  Future<void> _handleSave() async {
    // 1. Validação dos campos do formulário
    if (!_formKey.currentState!.validate()) return;
    if (_user == null) return;
    setState(() {
      _isSaving = true;
    });
    try {
      final updatedUser = await _authService.updateUserProfile(
        uid: _user!.uid,
        name: _nameController.text,
        username: _usernameController.text,
        currentUsername: _user!.username,
      );
      if (!mounted) return;
      setState(() {
        _user = updatedUser;
        _nameController.text = updatedUser.name;
        _usernameController.text = updatedUser.username;
        _isEditing = false;
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil atualizado com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar alterações: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _cancelEditing() {
    if (_user != null) {
      setState(() {
        _nameController.text = _user!.name;
        _usernameController.text = _user!.username;
        _isEditing = false;
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Não informada';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();
    return '$day/$month/$year';
  }

  String _getInitials(String name) {
    final clean = name.trim();
    if (clean.isEmpty) return 'Δ';
    final parts = clean.split(RegExp(r'\s+'));
    if (parts.length == 1) {
      return parts[0][0].toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair da conta'),
        content: const Text('Tem certeza de que deseja sair?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sair'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _authService.logout();
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu Perfil'),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: Icon(_isEditing ? Icons.close : Icons.edit),
              tooltip: _isEditing ? 'Cancelar edição' : 'Editar perfil',
              onPressed: _isSaving
                  ? null
                  : () {
                      if (_isEditing) {
                        _cancelEditing();
                      } else {
                        setState(() {
                          _isEditing = true;
                        });
                      }
                    },
            ),
        ],
      ),
      body: _buildBody(),
    );
  }
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadUserProfile,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // 1. Avatar com Iniciais e Cabeçalho
            CircleAvatar(
              radius: 44,
              backgroundColor: Theme.of(context).primaryColor,
              child: Text(
                _getInitials(_nameController.text),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _user?.name ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${_user?.username ?? ''}',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            // 2. Campo: Nome Completo
            TextFormField(
              controller: _nameController,
              enabled: _isEditing && !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Nome Completo',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, informe seu nome.';
                }
                if (value.trim().length < 3) {
                  return 'O nome deve ter pelo menos 3 caracteres.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 3. Campo: Nome de Usuário (@username)
            TextFormField(
              controller: _usernameController,
              enabled: _isEditing && !_isSaving,
              decoration: const InputDecoration(
                labelText: 'Nome de Usuário',
                prefixIcon: Icon(Icons.alternate_email),
                prefixText: '@',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Por favor, informe seu nome de usuário.';
                }
                if (value.trim().length < 3) {
                  return 'O nome de usuário deve ter pelo menos 3 caracteres.';
                }
                if (value.contains(' ')) {
                  return 'O nome de usuário não pode conter espaços.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            // 4. Campo: E-mail (Bloqueado / Somente Leitura)
            TextFormField(
              controller: _emailController,
              enabled: false,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email),
                suffixIcon: Icon(Icons.lock, size: 18),
                border: OutlineInputBorder(),
                helperText: 'O e-mail não pode ser alterado.',
              ),
            ),
            const SizedBox(height: 16),
            // 5. Informação: Membro desde (Data de Cadastro)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text(
                'Membro desde',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              subtitle: Text(
                _formatDate(_user?.createdAt),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 24),
            // 6. Botões de Ação
            if (_isEditing) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSaving ? null : _cancelEditing,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _handleSave,
                      child: _isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Salvar'),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _confirmLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Sair da Conta',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}