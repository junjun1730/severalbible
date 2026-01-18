# Phase 3: 기도 노트 시스템 - TDD 체크리스트

**목표**: 사용자가 묵상을 기록하고 조회할 수 있는 기능 구현. 티어별 조회 제한 적용.

**전체 항목**: 78개
**커버리지 목표**: Repository 95%+, Service 95%+, Provider 90%+, Widget 80%+
**예상 소요 기간**: 6-8일

---

## 3-1. 데이터베이스 & RLS

### Prayer Notes 테이블

#### Prayer Notes 테이블 생성
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.1 | 🟢 GREEN | `prayer_notes` 테이블 스키마 생성 | [x] |
| 1.1 | 🟢 GREEN | `scriptures` 테이블에 외래키 추가 | [x] |
| 1.1 | 🔵 REFACTOR | 데이터 무결성 및 인덱스 검증 | [x] |

**Migration File Created**: `supabase/migrations/006_create_prayer_notes.sql`

**SQL 스키마**:
```sql
CREATE TABLE prayer_notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  scripture_id UUID REFERENCES scriptures(id) ON DELETE SET NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 성능을 위한 인덱스 생성
CREATE INDEX idx_prayer_notes_user_id ON prayer_notes(user_id);
CREATE INDEX idx_prayer_notes_created_at ON prayer_notes(created_at);
CREATE INDEX idx_prayer_notes_user_date ON prayer_notes(user_id, DATE(created_at));
```

### RLS 정책

#### Guest RLS (접근 금지)
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.2 | 🔴 RED | SQL 테스트 작성: Guest는 기도노트 생성 불가 | [x] |
| 1.2 | 🔴 RED | SQL 테스트 작성: Guest는 기도노트 조회 불가 | [x] |
| 1.2 | 🟢 GREEN | RLS 정책 구현: 비인증 사용자 모든 접근 거부 | [x] |

#### Member RLS (최근 3일)
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.3 | 🔴 RED | SQL 테스트 작성: Member는 자신의 기도노트 생성 가능 | [x] |
| 1.3 | 🔴 RED | SQL 테스트 작성: Member는 최근 3일 노트 조회 가능 | [x] |
| 1.3 | 🔴 RED | SQL 테스트 작성: Member는 3일 이전 노트 조회 불가 | [x] |
| 1.3 | 🔴 RED | SQL 테스트 작성: Member는 최근 노트 수정 가능 | [x] |
| 1.3 | 🔴 RED | SQL 테스트 작성: Member는 최근 노트 삭제 가능 | [x] |
| 1.3 | 🟢 GREEN | Member 티어용 RLS 정책 구현 | [x] |

**RLS 정책 예시**:
```sql
-- Member 티어: 최근 3일만 조회 가능
CREATE POLICY "Members can view recent notes" ON prayer_notes
  FOR SELECT USING (
    auth.uid() = user_id
    AND created_at >= NOW() - INTERVAL '3 days'
  );
```

#### Premium RLS (전체 기간)
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.4 | 🔴 RED | SQL 테스트 작성: Premium은 모든 기도노트 조회 가능 | [x] |
| 1.4 | 🔴 RED | SQL 테스트 작성: Premium은 모든 자신의 노트 수정 가능 | [x] |
| 1.4 | 🔴 RED | SQL 테스트 작성: Premium은 모든 자신의 노트 삭제 가능 | [x] |
| 1.4 | 🟢 GREEN | Premium 티어용 RLS 정책 구현 | [x] |

**RLS 정책 예시**:
```sql
-- Premium 티어: 전체 기간 조회 가능
CREATE POLICY "Premium can view all notes" ON prayer_notes
  FOR SELECT USING (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM user_profiles
      WHERE id = auth.uid() AND tier = 'premium'
    )
  );
```

### RPC 함수

#### RPC: create_prayer_note
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.5 | 🔴 RED | SQL 테스트 작성: 기도노트 생성 | [x] |
| 1.5 | 🔴 RED | SQL 테스트 작성: 사용자 인증 검증 | [x] |
| 1.5 | 🔴 RED | SQL 테스트 작성: 생성된 노트 반환 | [x] |
| 1.5 | 🟢 GREEN | `create_prayer_note` RPC 구현 | [x] |

#### RPC: get_prayer_notes
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.6 | 🔴 RED | SQL 테스트 작성: 날짜 범위별 노트 반환 | [x] |
| 1.6 | 🔴 RED | SQL 테스트 작성: 티어별 필터링 적용 | [x] |
| 1.6 | 🔴 RED | SQL 테스트 작성: 성경 구절 정보 포함 반환 | [x] |
| 1.6 | 🟢 GREEN | `get_prayer_notes` RPC 구현 | [x] |

#### RPC: get_prayer_notes_by_date
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.7 | 🔴 RED | SQL 테스트 작성: 특정 날짜 노트 반환 | [x] |
| 1.7 | 🔴 RED | SQL 테스트 작성: 노트 없는 날짜는 빈 배열 반환 | [x] |
| 1.7 | 🟢 GREEN | `get_prayer_notes_by_date` RPC 구현 | [x] |

#### RPC: update_prayer_note
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.8 | 🔴 RED | SQL 테스트 작성: 노트 내용 수정 | [x] |
| 1.8 | 🔴 RED | SQL 테스트 작성: updated_at 타임스탬프 갱신 | [x] |
| 1.8 | 🔴 RED | SQL 테스트 작성: 소유권 검증 | [x] |
| 1.8 | 🟢 GREEN | `update_prayer_note` RPC 구현 | [x] |

#### RPC: delete_prayer_note
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.9 | 🔴 RED | SQL 테스트 작성: 노트 삭제 | [x] |
| 1.9 | 🔴 RED | SQL 테스트 작성: 소유권 검증 | [x] |
| 1.9 | 🟢 GREEN | `delete_prayer_note` RPC 구현 | [x] |

**Migration File Created**: `supabase/migrations/007_create_prayer_note_rpc_functions.sql`

**RPC Functions Implemented (7개)**:
- `create_prayer_note(p_content, p_scripture_id)` - 기도노트 생성
- `get_prayer_notes(p_start_date, p_end_date, p_limit, p_offset)` - 노트 목록 조회
- `get_prayer_notes_by_date(p_date)` - 특정 날짜 노트 조회
- `update_prayer_note(p_note_id, p_content)` - 노트 수정
- `delete_prayer_note(p_note_id)` - 노트 삭제
- `is_date_accessible(p_date)` - 날짜 접근 가능 여부 확인
- `get_notes_count_by_date_range(p_start_date, p_end_date)` - 캘린더용 날짜별 노트 수

### Edge Function: 오래된 노트 자동 삭제

#### Edge Function 설정
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 1.10 | 🔴 RED | 테스트 작성: Member의 7일 이전 노트 삭제 | [x] |
| 1.10 | 🔴 RED | 테스트 작성: Premium 노트는 보존 | [x] |
| 1.10 | 🔴 RED | 테스트 작성: 스케줄(cron) 실행 | [x] |
| 1.10 | 🟢 GREEN | `cleanup_old_notes` Edge Function 구현 | [x] |
| 1.10 | 🟢 GREEN | cron 스케줄 설정 (매일 자정) | [ ] |

**Edge Function Created**: `supabase/functions/cleanup-old-notes/index.ts`
**pgTAP Test File Created**: `supabase/tests/prayer_note_test.sql` (20개 테스트)

**Edge Function 예시**:
```typescript
// supabase/functions/cleanup-old-notes/index.ts
import { createClient } from '@supabase/supabase-js';

Deno.serve(async () => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  // 비프리미엄 사용자의 7일 이전 노트 삭제
  const { error } = await supabase
    .from('prayer_notes')
    .delete()
    .lt('created_at', new Date(Date.now() - 7 * 24 * 60 * 60 * 1000).toISOString())
    .in('user_id',
      supabase.from('user_profiles').select('id').neq('tier', 'premium')
    );

  return new Response(JSON.stringify({ success: !error }));
});
```

---

## 3-2. 기도 노트 기능 (TDD)

### 도메인 레이어

#### PrayerNote 엔티티
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.1 | 🟢 GREEN | freezed로 `PrayerNote` 엔티티 생성 | [ ] |
| 2.1 | 🔵 REFACTOR | 불변성 및 copyWith 검증 | [ ] |

**엔티티 정의** (`lib/features/prayer_note/domain/entities/prayer_note.dart`):
```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../scripture/domain/entities/scripture.dart';

part 'prayer_note.freezed.dart';
part 'prayer_note.g.dart';

@freezed
class PrayerNote with _$PrayerNote {
  const factory PrayerNote({
    required String id,
    required String userId,
    String? scriptureId,
    required String content,
    required DateTime createdAt,
    required DateTime updatedAt,
    Scripture? scripture, // 조인된 성경 데이터
  }) = _PrayerNote;

  factory PrayerNote.fromJson(Map<String, dynamic> json) =>
      _$PrayerNoteFromJson(json);
}
```

#### PrayerNoteRepository 인터페이스
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.2 | 🟢 GREEN | `PrayerNoteRepository` 인터페이스 생성 | [ ] |

**Repository 인터페이스** (`lib/features/prayer_note/domain/repositories/prayer_note_repository.dart`):
```dart
import 'package:dartz/dartz.dart';
import '../entities/prayer_note.dart';
import '../../../../core/errors/failures.dart';

abstract class PrayerNoteRepository {
  /// 새 기도 노트 생성
  Future<Either<Failure, PrayerNote>> createPrayerNote({
    required String userId,
    required String content,
    String? scriptureId,
  });

  /// 날짜 범위별 기도 노트 조회 (티어 기반)
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotes({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// 특정 날짜의 기도 노트 조회
  Future<Either<Failure, List<PrayerNote>>> getPrayerNotesByDate({
    required String userId,
    required DateTime date,
  });

  /// 기도 노트 수정
  Future<Either<Failure, PrayerNote>> updatePrayerNote({
    required String noteId,
    required String content,
  });

  /// 기도 노트 삭제
  Future<Either<Failure, void>> deletePrayerNote({
    required String noteId,
  });

  /// 사용자 티어에 따른 날짜 접근 가능 여부 확인
  Future<Either<Failure, bool>> isDateAccessible({
    required String userId,
    required DateTime date,
  });
}
```

### 데이터 레이어 - PrayerNoteRepository 테스트

#### 테스트 설정 & Mock
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.3 | 🔴 RED | 테스트 파일 및 Mock 설정 | [ ] |
| 2.3 | 🔴 RED | `MockPrayerNoteDataSource` 생성 | [ ] |

**테스트 파일**: `test/features/prayer_note/data/repositories/prayer_note_repository_test.dart`

#### createPrayerNote 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.4 | 🔴 RED | 테스트 `createPrayerNote` 성공 시 Right(note) 반환 | [ ] |
| 2.4 | 🔴 RED | 테스트 `createPrayerNote` 성경 참조 포함 | [ ] |
| 2.4 | 🔴 RED | 테스트 `createPrayerNote` 에러 시 Left(failure) 반환 | [ ] |
| 2.4 | 🔴 RED | 테스트 `createPrayerNote` 빈 내용 검증 | [ ] |
| 2.4 | 🟢 GREEN | `createPrayerNote` 구현 | [ ] |

#### getPrayerNotes 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.5 | 🔴 RED | 테스트 `getPrayerNotes` 성공 시 Right(notes) 반환 | [ ] |
| 2.5 | 🔴 RED | 테스트 `getPrayerNotes` 날짜 범위 필터링 | [ ] |
| 2.5 | 🔴 RED | 테스트 `getPrayerNotes` 성경 정보 포함 | [ ] |
| 2.5 | 🔴 RED | 테스트 `getPrayerNotes` 노트 없을 시 빈 리스트 반환 | [ ] |
| 2.5 | 🔴 RED | 테스트 `getPrayerNotes` 에러 시 Left(failure) 반환 | [ ] |
| 2.5 | 🟢 GREEN | `getPrayerNotes` 구현 | [ ] |

#### getPrayerNotesByDate 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.6 | 🔴 RED | 테스트 `getPrayerNotesByDate` 해당 날짜 노트 반환 | [ ] |
| 2.6 | 🔴 RED | 테스트 `getPrayerNotesByDate` 노트 없을 시 빈 리스트 반환 | [ ] |
| 2.6 | 🔴 RED | 테스트 `getPrayerNotesByDate` 에러 시 Left(failure) 반환 | [ ] |
| 2.6 | 🟢 GREEN | `getPrayerNotesByDate` 구현 | [ ] |

#### updatePrayerNote 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.7 | 🔴 RED | 테스트 `updatePrayerNote` 수정된 노트 반환 | [ ] |
| 2.7 | 🔴 RED | 테스트 `updatePrayerNote` 타임스탬프 갱신 | [ ] |
| 2.7 | 🔴 RED | 테스트 `updatePrayerNote` 노트 없을 시 Left(failure) 반환 | [ ] |
| 2.7 | 🔴 RED | 테스트 `updatePrayerNote` 에러 시 Left(failure) 반환 | [ ] |
| 2.7 | 🟢 GREEN | `updatePrayerNote` 구현 | [ ] |

#### deletePrayerNote 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.8 | 🔴 RED | 테스트 `deletePrayerNote` 성공 시 Right(void) 반환 | [ ] |
| 2.8 | 🔴 RED | 테스트 `deletePrayerNote` 노트 없을 시 Left(failure) 반환 | [ ] |
| 2.8 | 🔴 RED | 테스트 `deletePrayerNote` 에러 시 Left(failure) 반환 | [ ] |
| 2.8 | 🟢 GREEN | `deletePrayerNote` 구현 | [ ] |

#### isDateAccessible 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.9 | 🔴 RED | 테스트 `isDateAccessible` 오늘 날짜 모든 티어 true 반환 | [ ] |
| 2.9 | 🔴 RED | 테스트 `isDateAccessible` 3일 전 날짜 member true 반환 | [ ] |
| 2.9 | 🔴 RED | 테스트 `isDateAccessible` 4일+ 이전 날짜 member false 반환 | [ ] |
| 2.9 | 🔴 RED | 테스트 `isDateAccessible` 모든 날짜 premium true 반환 | [ ] |
| 2.9 | 🟢 GREEN | `isDateAccessible` 구현 | [ ] |

### 데이터 레이어 - 구현

#### PrayerNoteDataSource
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.10 | 🟢 GREEN | `PrayerNoteDataSource` 인터페이스 생성 | [ ] |
| 2.10 | 🟢 GREEN | `SupabasePrayerNoteDataSource` 구현 | [ ] |
| 2.10 | 🔵 REFACTOR | JSON 매핑 로직 추출 | [ ] |

**DataSource 파일**: `lib/features/prayer_note/data/datasources/prayer_note_datasource.dart`

#### PrayerNoteRepository 구현
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 2.11 | 🟢 GREEN | `SupabasePrayerNoteRepository` 구현 | [ ] |
| 2.11 | 🔵 REFACTOR | 포괄적인 에러 처리 추가 | [ ] |
| 2.11 | 🔵 REFACTOR | 모든 테스트 통과 검증 | [ ] |

**Repository 파일**: `lib/features/prayer_note/data/repositories/supabase_prayer_note_repository.dart`

### 상태 레이어 - Provider

#### PrayerNoteListProvider
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 3.1 | 🔴 RED | 테스트 provider가 선택된 날짜의 노트 로드 | [ ] |
| 3.1 | 🔴 RED | 테스트 provider가 로딩 상태 처리 | [ ] |
| 3.1 | 🔴 RED | 테스트 provider가 에러 상태 처리 | [ ] |
| 3.1 | 🔴 RED | 테스트 provider가 날짜 변경 시 새로고침 | [ ] |
| 3.1 | 🟢 GREEN | `PrayerNoteListProvider` 구현 | [ ] |

#### PrayerNoteFormController
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 3.2 | 🔴 RED | 테스트 controller가 새 노트 생성 | [ ] |
| 3.2 | 🔴 RED | 테스트 controller가 기존 노트 수정 | [ ] |
| 3.2 | 🔴 RED | 테스트 controller가 노트 삭제 | [ ] |
| 3.2 | 🔴 RED | 테스트 controller가 내용 검증 | [ ] |
| 3.2 | 🟢 GREEN | `PrayerNoteFormController` 구현 | [ ] |

#### DateAccessibilityProvider
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 3.3 | 🔴 RED | 테스트 provider가 날짜별 접근 가능 여부 반환 | [ ] |
| 3.3 | 🔴 RED | 테스트 provider가 티어 변경 처리 | [ ] |
| 3.3 | 🟢 GREEN | `DateAccessibilityProvider` 구현 | [ ] |

#### Provider 설정
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 3.4 | 🟢 GREEN | `prayerNoteRepositoryProvider` 생성 | [ ] |
| 3.4 | 🟢 GREEN | `prayerNoteDataSourceProvider` 생성 | [ ] |
| 3.4 | 🟢 GREEN | `prayerNoteListProvider` 생성 | [ ] |
| 3.4 | 🟢 GREEN | `selectedDateProvider` 생성 | [ ] |
| 3.4 | 🟢 GREEN | `dateAccessibilityProvider` 생성 | [ ] |

---

## 3-3. UI 구현

### PrayerNoteInput 위젯

#### PrayerNoteInput 위젯 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.1 | 🔴 RED | 위젯 테스트: 텍스트 필드 렌더링 | [ ] |
| 4.1 | 🔴 RED | 위젯 테스트: 글자 수 표시 | [ ] |
| 4.1 | 🔴 RED | 위젯 테스트: guest 티어 비활성화 | [ ] |
| 4.1 | 🔴 RED | 위젯 테스트: 저장 버튼 표시 | [ ] |
| 4.1 | 🔴 RED | 위젯 테스트: onSave 콜백 호출 | [ ] |
| 4.1 | 🔴 RED | 위젯 테스트: 빈 내용 검증 | [ ] |
| 4.1 | 🟢 GREEN | `PrayerNoteInput` 위젯 구현 | [ ] |
| 4.1 | 🔵 REFACTOR | 자동 저장 기능 추가 (선택사항) | [ ] |

**위젯 파일**: `lib/features/prayer_note/presentation/widgets/prayer_note_input.dart`

### PrayerNoteCard 위젯

#### PrayerNoteCard 위젯 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.2 | 🔴 RED | 위젯 테스트: 노트 내용 렌더링 | [ ] |
| 4.2 | 🔴 RED | 위젯 테스트: 성경 참조 렌더링 (있을 경우) | [ ] |
| 4.2 | 🔴 RED | 위젯 테스트: 생성 날짜 렌더링 | [ ] |
| 4.2 | 🔴 RED | 위젯 테스트: 수정 버튼 표시 | [ ] |
| 4.2 | 🔴 RED | 위젯 테스트: 삭제 버튼 표시 | [ ] |
| 4.2 | 🔴 RED | 위젯 테스트: onEdit 콜백 호출 | [ ] |
| 4.2 | 🔴 RED | 위젯 테스트: onDelete 콜백 호출 | [ ] |
| 4.2 | 🟢 GREEN | `PrayerNoteCard` 위젯 구현 | [ ] |

**위젯 파일**: `lib/features/prayer_note/presentation/widgets/prayer_note_card.dart`

### MyLibraryScreen

#### MyLibraryScreen 위젯 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.3 | 🔴 RED | 위젯 테스트: 로딩 인디케이터 표시 | [ ] |
| 4.3 | 🔴 RED | 위젯 테스트: 캘린더 렌더링 | [ ] |
| 4.3 | 🔴 RED | 위젯 테스트: 선택된 날짜의 노트 목록 표시 | [ ] |
| 4.3 | 🔴 RED | 위젯 테스트: 노트 없을 시 빈 상태 표시 | [ ] |
| 4.3 | 🔴 RED | 위젯 테스트: 에러 상태 표시 | [ ] |
| 4.3 | 🔴 RED | 위젯 테스트: 날짜 선택 시 업데이트 | [ ] |
| 4.3 | 🟢 GREEN | `MyLibraryScreen` 구현 | [ ] |

**스크린 파일**: `lib/features/prayer_note/presentation/screens/my_library_screen.dart`

### 캘린더 연동

#### 캘린더 위젯 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.4 | 🔴 RED | 위젯 테스트: 현재 월 표시 | [ ] |
| 4.4 | 🔴 RED | 위젯 테스트: 노트 있는 날짜 하이라이트 | [ ] |
| 4.4 | 🔴 RED | 위젯 테스트: 날짜 선택 허용 | [ ] |
| 4.4 | 🔴 RED | 위젯 테스트: 월 이동 | [ ] |
| 4.4 | 🟢 GREEN | `table_calendar`로 캘린더 구현 | [ ] |

**위젯 파일**: `lib/features/prayer_note/presentation/widgets/prayer_calendar.dart`

### Member 티어용 잠금 아이콘

#### DateAccessibilityIndicator 테스트
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.5 | 🔴 RED | 위젯 테스트: 접근 불가 날짜에 잠금 아이콘 표시 | [ ] |
| 4.5 | 🔴 RED | 위젯 테스트: 접근 가능 날짜에 일반/해제 표시 | [ ] |
| 4.5 | 🔴 RED | 위젯 테스트: 잠긴 날짜 탭 시 프리미엄 업셀 표시 | [ ] |
| 4.5 | 🟢 GREEN | `DateAccessibilityIndicator` 위젯 구현 | [ ] |

**위젯 파일**: `lib/features/prayer_note/presentation/widgets/date_accessibility_indicator.dart`

### 통합 테스트

#### Guest 티어 통합
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.6 | 🔴 RED | 통합 테스트: guest는 비활성화된 입력 필드 확인 | [ ] |
| 4.6 | 🔴 RED | 통합 테스트: guest는 로그인 프롬프트 확인 | [ ] |
| 4.6 | 🟢 GREEN | guest 티어 제한 구현 | [ ] |

#### Member 티어 통합
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.7 | 🔴 RED | 통합 테스트: member는 노트 생성 가능 | [ ] |
| 4.7 | 🔴 RED | 통합 테스트: member는 최근 3일 노트 확인 | [ ] |
| 4.7 | 🔴 RED | 통합 테스트: member는 오래된 날짜에 잠금 표시 확인 | [ ] |
| 4.7 | 🔴 RED | 통합 테스트: member는 프리미엄 업셀 확인 | [ ] |
| 4.7 | 🟢 GREEN | member 티어 로직 구현 | [ ] |

#### Premium 티어 통합
| 사이클 | 단계 | 작업 | 상태 |
|-------|------|------|------|
| 4.8 | 🔴 RED | 통합 테스트: premium은 모든 노트 조회 가능 | [ ] |
| 4.8 | 🔴 RED | 통합 테스트: premium은 잠금 없음 | [ ] |
| 4.8 | 🔴 RED | 통합 테스트: premium은 모든 노트 수정 가능 | [ ] |
| 4.8 | 🟢 GREEN | premium 티어 로직 구현 | [ ] |

---

## 테스트 파일 위치

| 테스트 유형 | 파일 경로 | 테스트 수 |
|-----------|----------|----------|
| RLS/RPC 테스트 (SQL) | `supabase/tests/prayer_note_test.sql` | 20 |
| Edge Function 테스트 | `supabase/functions/cleanup-old-notes/test.ts` | 3 |
| PrayerNoteRepository | `test/features/prayer_note/data/repositories/prayer_note_repository_test.dart` | 22 |
| PrayerNoteListProvider | `test/features/prayer_note/presentation/providers/prayer_note_list_provider_test.dart` | 4 |
| PrayerNoteFormController | `test/features/prayer_note/presentation/providers/prayer_note_form_controller_test.dart` | 4 |
| PrayerNoteInput 위젯 | `test/features/prayer_note/presentation/widgets/prayer_note_input_test.dart` | 6 |
| PrayerNoteCard 위젯 | `test/features/prayer_note/presentation/widgets/prayer_note_card_test.dart` | 7 |
| MyLibraryScreen | `test/features/prayer_note/presentation/screens/my_library_screen_test.dart` | 6 |
| Calendar 위젯 | `test/features/prayer_note/presentation/widgets/prayer_calendar_test.dart` | 4 |
| Guest 통합 | `integration_test/guest_prayer_note_flow_test.dart` | 2 |
| Member 통합 | `integration_test/member_prayer_note_flow_test.dart` | 4 |
| Premium 통합 | `integration_test/premium_prayer_note_flow_test.dart` | 3 |

**총 테스트 케이스**: 85개

---

## 구현 파일 위치

| 컴포넌트 | 파일 경로 |
|---------|----------|
| PrayerNote 엔티티 | `lib/features/prayer_note/domain/entities/prayer_note.dart` |
| PrayerNoteRepository 인터페이스 | `lib/features/prayer_note/domain/repositories/prayer_note_repository.dart` |
| PrayerNoteDataSource | `lib/features/prayer_note/data/datasources/prayer_note_datasource.dart` |
| SupabasePrayerNoteDataSource | `lib/features/prayer_note/data/datasources/supabase_prayer_note_datasource.dart` |
| SupabasePrayerNoteRepository | `lib/features/prayer_note/data/repositories/supabase_prayer_note_repository.dart` |
| PrayerNoteListProvider | `lib/features/prayer_note/presentation/providers/prayer_note_list_provider.dart` |
| PrayerNoteFormController | `lib/features/prayer_note/presentation/providers/prayer_note_form_controller.dart` |
| Prayer Note Providers | `lib/features/prayer_note/presentation/providers/prayer_note_providers.dart` |
| PrayerNoteInput 위젯 | `lib/features/prayer_note/presentation/widgets/prayer_note_input.dart` |
| PrayerNoteCard 위젯 | `lib/features/prayer_note/presentation/widgets/prayer_note_card.dart` |
| PrayerCalendar 위젯 | `lib/features/prayer_note/presentation/widgets/prayer_calendar.dart` |
| DateAccessibilityIndicator | `lib/features/prayer_note/presentation/widgets/date_accessibility_indicator.dart` |
| MyLibraryScreen | `lib/features/prayer_note/presentation/screens/my_library_screen.dart` |

---

## 의존성 그래프

```
Phase 3-1 (데이터베이스 & RLS)
    ↓
Phase 3-2 (기도 노트 기능 - TDD)
    ├─ 도메인 레이어 (엔티티, 인터페이스)
    ├─ 데이터 레이어 테스트 (PrayerNoteRepository)
    ├─ 데이터 레이어 구현
    └─ 상태 레이어 (Providers)
        ↓
Phase 3-3 (UI 구현)
    ├─ PrayerNoteInput 위젯
    ├─ PrayerNoteCard 위젯
    ├─ PrayerCalendar 위젯
    ├─ DateAccessibilityIndicator
    ├─ MyLibraryScreen
    └─ 통합 테스트
```

---

## 일별 진행 마일스톤

### 1-2일차: 데이터베이스 & RLS 설정
- prayer_notes 테이블 생성
- 모든 티어용 RLS 정책 구현
- RPC 함수 구현 (CRUD)
- SQL 테스트 작성 (pgTAP)
- 자동 삭제 Edge Function 배포

### 3-4일차: 도메인 & 데이터 레이어 (TDD)
- PrayerNote 엔티티 정의
- Repository 인터페이스 생성
- 22개 이상의 Repository 테스트 작성
- DataSource 구현
- Repository 구현
- 모든 테스트 통과 검증

### 5일차: 상태 레이어 & Provider
- PrayerNoteListProvider 구현
- PrayerNoteFormController 구현
- DateAccessibilityProvider 구현
- Provider 테스트 작성
- Provider 의존성 설정

### 6-7일차: UI 구현
- PrayerNoteInput 위젯 구현 (6개 테스트)
- PrayerNoteCard 위젯 구현 (7개 테스트)
- PrayerCalendar 위젯 구현 (4개 테스트)
- MyLibraryScreen 구현 (6개 테스트)
- UI와 Provider 연결

### 8일차: 통합 & 테스트
- Guest 티어 통합 테스트 작성
- Member 티어 통합 테스트 작성
- Premium 티어 통합 테스트 작성
- End-to-end 플로우 테스트
- 버그 수정 및 개선
- 문서 업데이트

---

## RLS 정책 요약

### Prayer Notes 테이블 - 티어별 접근
```sql
-- RLS 활성화
ALTER TABLE prayer_notes ENABLE ROW LEVEL SECURITY;

-- 기본 정책: 사용자는 자신의 노트만 접근 가능
CREATE POLICY "Users can access own notes" ON prayer_notes
  FOR ALL USING (auth.uid() = user_id);

-- Member 티어: 최근 3일만 조회 (복잡한 로직은 RPC 사용)
-- Premium 티어: 전체 조회 (user_profiles의 tier 확인으로 처리)

-- Insert 정책: 인증된 사용자만
CREATE POLICY "Authenticated users can create notes" ON prayer_notes
  FOR INSERT WITH CHECK (auth.uid() = user_id AND auth.uid() IS NOT NULL);

-- Update 정책: 자신의 노트만
CREATE POLICY "Users can update own notes" ON prayer_notes
  FOR UPDATE USING (auth.uid() = user_id);

-- Delete 정책: 자신의 노트만
CREATE POLICY "Users can delete own notes" ON prayer_notes
  FOR DELETE USING (auth.uid() = user_id);
```

---

## 테스트 커버리지 목표

| 레이어 | 목표 커버리지 | 우선순위 |
|-------|-------------|---------|
| PrayerNoteRepository | 95%+ | 최고 |
| PrayerNote 도메인 | 95%+ | 최고 |
| PrayerNoteProviders | 90%+ | 높음 |
| PrayerNoteInput 위젯 | 80%+ | 중간 |
| MyLibraryScreen | 80%+ | 중간 |
| RPC 함수 (SQL) | 90%+ | 높음 |
| Edge Function | 90%+ | 높음 |
| 통합 테스트 | 전체 플로우 | 높음 |

---

## 진행 현황 요약

| 섹션 | 전체 | 완료 | 진행률 |
|------|-----|-----|-------|
| 3-1. 데이터베이스 & RLS | 28 | 27 | 96% |
| 3-2. 기도 노트 기능 (TDD) | 34 | 0 | 0% |
| 3-3. UI 구현 | 37 | 0 | 0% |
| **전체** | **99** | **27** | **27%** |

### 생성된 파일 요약
- `supabase/migrations/006_create_prayer_notes.sql` - 테이블 + RLS 정책
- `supabase/migrations/007_create_prayer_note_rpc_functions.sql` - RPC 함수 7개
- `supabase/tests/prayer_note_test.sql` - pgTAP 테스트 20개
- `supabase/functions/cleanup-old-notes/index.ts` - Edge Function

---

**최종 업데이트**: 2026-01-18
**Phase 상태**: 3-1 완료 (마이그레이션 적용 대기)
