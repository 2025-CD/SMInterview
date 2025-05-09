package sm.ac.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class JobCategoryDto {

    private int jobcategoryid;
    private int jobfieldid;  // job_fields 테이블의 FK
    private String categoryName;
}
