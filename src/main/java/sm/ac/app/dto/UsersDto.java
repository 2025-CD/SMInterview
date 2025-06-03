package sm.ac.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UsersDto {
    private String id;
    private String username;
    private String password;
    private String email;
    private String role;
    private int job_field_id;
    private int job_category_id;
}
